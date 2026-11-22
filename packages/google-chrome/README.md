# google-chrome

The packaged desktop launchers already enable Ozone, VA-API, and PipeWire camera support on `nabu`.

For terminal launches, add the camera flag manually:

```bash
google-chrome-stable --enable-features=WebRtcPipeWireCamera
```

Install the camera backend if it is missing:

```bash
sudo pacman -S pipewire-libcamera
```
