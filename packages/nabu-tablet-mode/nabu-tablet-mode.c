// SPDX-License-Identifier: GPL-2.0-only
#define _GNU_SOURCE

#include <ctype.h>
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <linux/input-event-codes.h>
#include <linux/input.h>
#include <linux/uinput.h>
#include <signal.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <time.h>
#include <unistd.h>

#define DEVICE_NAME "Nabu Tablet Mode Switch"
#define USER_SHELL_DELAY_TICKS 25
#define POLL_NSEC 200000000L
#define RUN_MODE_FILE "/run/nabu-tablet-mode/mode"
#define CONF_FILE "/etc/nabu-tablet-mode.conf"

#define test_bit(bit, array) ((array[(bit) / 8] >> ((bit) % 8)) & 1)

typedef enum {
	MODE_AUTO = 0,
	MODE_TABLET = 1,
	MODE_LAPTOP = 2,
} tablet_op_mode_t;

static volatile sig_atomic_t stopping;
static volatile sig_atomic_t retrigger;
static volatile sig_atomic_t reload_mode;

static void handle_signal(int signal_number)
{
	(void)signal_number;
	stopping = 1;
}

static void handle_usr1(int signal_number)
{
	(void)signal_number;
	retrigger = 1;
}

static void handle_usr2(int signal_number)
{
	(void)signal_number;
	reload_mode = 1;
}

static int emit_event(int fd, unsigned short type, unsigned short code,
		      int value)
{
	struct input_event event = {
		.type = type,
		.code = code,
		.value = value,
	};
	ssize_t written;

	written = write(fd, &event, sizeof(event));
	if (written == (ssize_t)sizeof(event))
		return 0;

	if (written >= 0)
		errno = EIO;
	return -1;
}

static int set_tablet_mode(int fd, bool enabled)
{
	if (emit_event(fd, EV_SW, SW_TABLET_MODE, enabled ? 1 : 0) < 0)
		return -1;

	return emit_event(fd, EV_SYN, SYN_REPORT, 0);
}

static tablet_op_mode_t parse_mode_string(const char *str)
{
	if (!str)
		return MODE_AUTO;
	while (*str == ' ' || *str == '\t')
		str++;
	if (strncasecmp(str, "tablet", 6) == 0)
		return MODE_TABLET;
	if (strncasecmp(str, "laptop", 6) == 0)
		return MODE_LAPTOP;
	return MODE_AUTO;
}

static const char *mode_name(tablet_op_mode_t mode)
{
	switch (mode) {
	case MODE_TABLET:
		return "force-tablet";
	case MODE_LAPTOP:
		return "force-laptop";
	case MODE_AUTO:
	default:
		return "auto";
	}
}

static tablet_op_mode_t read_configured_mode(void)
{
	FILE *f = fopen(RUN_MODE_FILE, "r");
	if (f) {
		char buf[32];
		if (fgets(buf, sizeof(buf), f)) {
			fclose(f);
			return parse_mode_string(buf);
		}
		fclose(f);
	}

	f = fopen(CONF_FILE, "r");
	if (f) {
		char line[128];
		while (fgets(line, sizeof(line), f)) {
			char *p = line;
			while (*p == ' ' || *p == '\t')
				p++;
			if (*p == '#' || *p == '\0' || *p == '\n')
				continue;
			if (strncasecmp(p, "mode", 4) == 0) {
				p += 4;
				while (*p == ' ' || *p == '\t')
					p++;
				if (*p == '=') {
					p++;
					while (*p == ' ' || *p == '\t')
						p++;
					tablet_op_mode_t m = parse_mode_string(p);
					fclose(f);
					return m;
				}
			}
		}
		fclose(f);
	}

	return MODE_AUTO;
}

static bool is_physical_keyboard_present(void)
{
	DIR *dir = opendir("/dev/input");
	if (!dir)
		return false;

	struct dirent *entry;
	bool found = false;

	while ((entry = readdir(dir))) {
		if (strncmp(entry->d_name, "event", 5) != 0)
			continue;

		char path[512];
		snprintf(path, sizeof(path), "/dev/input/%s", entry->d_name);

		int fd = open(path, O_RDONLY | O_NONBLOCK | O_CLOEXEC);
		if (fd < 0)
			continue;

		char name[128] = {0};
		ioctl(fd, EVIOCGNAME(sizeof(name) - 1), name);

		/* Ignore virtual devices, touchscreens, pens, audio jacks, and PMIC keys */
		if (strcasestr(name, "Tablet Mode") ||
		    strcasestr(name, "On-Screen") ||
		    strcasestr(name, "pwrkey") ||
		    strcasestr(name, "resin") ||
		    strcasestr(name, "gpio-keys") ||
		    strcasestr(name, "Headset") ||
		    strcasestr(name, "TouchScreen") ||
		    strcasestr(name, "Pen") ||
		    strcasestr(name, "Mouse")) {
			close(fd);
			continue;
		}

		unsigned char key_bits[KEY_CNT / 8 + 1] = {0};
		if (ioctl(fd, EVIOCGBIT(EV_KEY, sizeof(key_bits)), key_bits) >= 0) {
			/* Check for essential alphanumeric keyboard keys */
			if (test_bit(KEY_A, key_bits) &&
			    test_bit(KEY_Z, key_bits) &&
			    test_bit(KEY_SPACE, key_bits) &&
			    test_bit(KEY_ENTER, key_bits)) {
				found = true;
				close(fd);
				break;
			}
		}

		close(fd);
	}

	closedir(dir);
	return found;
}

static bool graphical_user_shell_running(void)
{
	struct dirent *entry;
	DIR *proc;
	bool found = false;

	proc = opendir("/proc");
	if (!proc)
		return false;

	while ((entry = readdir(proc))) {
		char path[64];
		char cmdline[256];
		char comm[32];
		struct stat statbuf;
		ssize_t cmdline_length;
		ssize_t length;
		int comm_fd;
		int cmdline_fd;
		char *end;
		long pid;

		pid = strtol(entry->d_name, &end, 10);
		if (*entry->d_name == '\0' || *end != '\0' || pid <= 0)
			continue;

		(void)snprintf(path, sizeof(path), "/proc/%ld", pid);
		if (stat(path, &statbuf) < 0 || statbuf.st_uid < 1000 ||
		    statbuf.st_uid == 65534)
			continue;

		(void)snprintf(path, sizeof(path), "/proc/%ld/comm", pid);
		comm_fd = open(path, O_RDONLY | O_CLOEXEC);
		if (comm_fd < 0)
			continue;
		length = read(comm_fd, comm, sizeof(comm) - 1);
		close(comm_fd);
		if (length <= 0)
			continue;
		comm[length] = '\0';
		bool is_gnome = (strcmp(comm, "gnome-shell\n") == 0 ||
				 strcmp(comm, "gnome-shell") == 0);
		bool is_plasma = (strcmp(comm, "kwin_wayland\n") == 0 ||
				  strcmp(comm, "kwin_wayland") == 0 ||
				  strcmp(comm, "plasmashell\n") == 0 ||
				  strcmp(comm, "plasmashell") == 0);

		if (!is_gnome && !is_plasma)
			continue;

		/*
		 * Greeters (GDM/SDDM) also run shells/compositors. Do not treat
		 * the greeter as the user's shell: if tablet mode is enabled before
		 * the real session starts, the compositor can inhibit orientation
		 * tracking during its native portrait initialization.
		 */
		(void)snprintf(path, sizeof(path), "/proc/%ld/cmdline", pid);
		cmdline_fd = open(path, O_RDONLY | O_CLOEXEC);
		if (cmdline_fd >= 0) {
			cmdline_length = read(cmdline_fd, cmdline,
					      sizeof(cmdline));
			close(cmdline_fd);
			if (cmdline_length > 0) {
				if (is_gnome && memmem(cmdline, (size_t)cmdline_length,
						       "--mode=gdm", strlen("--mode=gdm")))
					continue;
				if (is_plasma && memmem(cmdline, (size_t)cmdline_length,
							"greeter", strlen("greeter")))
					continue;
			}
		}

		found = true;
		break;
	}

	closedir(proc);
	return found;
}

int main(int argc, char **argv)
{
	struct uinput_setup setup = {
		.id = {
			.bustype = BUS_HOST,
			.vendor = 0x2717,
			.product = 0x0001,
			.version = 1,
		},
	};
	struct sigaction action = {
		.sa_handler = handle_signal,
	};
	struct sigaction usr1_action = {
		.sa_handler = handle_usr1,
		.sa_flags = SA_RESTART,
	};
	struct sigaction usr2_action = {
		.sa_handler = handle_usr2,
		.sa_flags = SA_RESTART,
	};
	int fd;
	int status = EXIT_FAILURE;
	unsigned int shell_ticks = 0;
	unsigned int kbd_poll_ticks = 0;
	bool enabled = false;
	tablet_op_mode_t op_mode = MODE_AUTO;

	if (argc != 1) {
		fprintf(stderr, "usage: %s\n", argv[0]);
		return EXIT_FAILURE;
	}

	fd = open("/dev/uinput", O_WRONLY | O_NONBLOCK | O_CLOEXEC);
	if (fd < 0) {
		perror("open /dev/uinput");
		return EXIT_FAILURE;
	}

	if (ioctl(fd, UI_SET_EVBIT, EV_SW) < 0 ||
	    ioctl(fd, UI_SET_SWBIT, SW_TABLET_MODE) < 0) {
		perror("configure uinput tablet switch");
		goto out_close;
	}

	(void)snprintf(setup.name, sizeof(setup.name), "%s", DEVICE_NAME);
	if (ioctl(fd, UI_DEV_SETUP, &setup) < 0 || ioctl(fd, UI_DEV_CREATE) < 0) {
		perror("create uinput tablet switch");
		goto out_close;
	}

	/*
	 * Start in laptop mode. Mutter and KWin give native-portrait panels an
	 * initial orientation update during session start.
	 */
	if (set_tablet_mode(fd, false) < 0) {
		perror("initialize tablet mode switch");
		goto out_destroy;
	}

	op_mode = read_configured_mode();
	printf(DEVICE_NAME ": SW_TABLET_MODE=OFF; mode=%s; waiting for graphical user shell\n",
	       mode_name(op_mode));
	fflush(stdout);

	sigemptyset(&action.sa_mask);
	if (sigaction(SIGINT, &action, NULL) < 0 ||
	    sigaction(SIGTERM, &action, NULL) < 0) {
		perror("sigaction");
		goto out_destroy;
	}

	sigemptyset(&usr1_action.sa_mask);
	if (sigaction(SIGUSR1, &usr1_action, NULL) < 0) {
		perror("sigaction SIGUSR1");
		goto out_destroy;
	}

	sigemptyset(&usr2_action.sa_mask);
	if (sigaction(SIGUSR2, &usr2_action, NULL) < 0) {
		perror("sigaction SIGUSR2");
		goto out_destroy;
	}

	while (!stopping) {
		struct timespec delay = {
			.tv_nsec = POLL_NSEC,
		};

		if (reload_mode) {
			reload_mode = 0;
			op_mode = read_configured_mode();
			printf(DEVICE_NAME ": mode reloaded -> %s\n", mode_name(op_mode));
			fflush(stdout);
		}

		if (retrigger) {
			retrigger = 0;
			if (enabled) {
				/* Pulse 1 -> 0 -> 1 so KWin/Mutter immediately re-claims SensorProxy */
				if (set_tablet_mode(fd, false) < 0)
					perror("pulse tablet mode off on retrigger");
				struct timespec pulse = { .tv_nsec = 50000000L }; /* 50ms */
				nanosleep(&pulse, NULL);
				if (set_tablet_mode(fd, true) < 0)
					perror("pulse tablet mode on on retrigger");
				printf(DEVICE_NAME ": SW_TABLET_MODE=ON (pulsed for wake/retrigger)\n");
				fflush(stdout);
			}
		}

		if (graphical_user_shell_running()) {
			bool initial_eval = false;
			if (shell_ticks < USER_SHELL_DELAY_TICKS) {
				shell_ticks++;
				if (shell_ticks == USER_SHELL_DELAY_TICKS)
					initial_eval = true;
			}

			/* Initial evaluation after delay, then periodic check every 1 second (5 ticks) */
			bool should_evaluate = initial_eval || (shell_ticks >= USER_SHELL_DELAY_TICKS && ++kbd_poll_ticks >= 5);

			if (should_evaluate) {
				kbd_poll_ticks = 0;
				bool desired = false;

				if (op_mode == MODE_TABLET) {
					desired = true;
				} else if (op_mode == MODE_LAPTOP) {
					desired = false;
				} else {
					/* MODE_AUTO: tablet mode when no physical keyboard is attached */
					bool kbd = is_physical_keyboard_present();
					desired = !kbd;
				}

				if (desired != enabled || initial_eval) {
					if (set_tablet_mode(fd, desired) < 0) {
						perror("update tablet mode");
						goto out_destroy;
					}
					enabled = desired;
					printf(DEVICE_NAME ": SW_TABLET_MODE=%s (mode=%s)\n",
					       enabled ? "ON" : "OFF", mode_name(op_mode));
					fflush(stdout);
				}
			}
		} else {
			shell_ticks = 0;
			kbd_poll_ticks = 0;
			if (enabled) {
				if (set_tablet_mode(fd, false) < 0) {
					perror("disable tablet mode on shell exit");
					goto out_destroy;
				}
				enabled = false;
				printf(DEVICE_NAME ": SW_TABLET_MODE=OFF; graphical user shell exited\n");
				fflush(stdout);
			}
		}

		while (!stopping && nanosleep(&delay, &delay) < 0 && errno == EINTR)
			;
	}

	status = EXIT_SUCCESS;
	if (enabled && set_tablet_mode(fd, false) < 0)
		perror("disable tablet mode");

out_destroy:
	if (ioctl(fd, UI_DEV_DESTROY) < 0)
		perror("destroy uinput tablet switch");
out_close:
	close(fd);
	return status;
}
