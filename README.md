# Jellyfin Video Format Optimizer

A set of command-line tools that help ensure your media files are encoded in a format fully compatible with **Jellyfin direct play**, without triggering CPU-heavy transcoding.

These scripts allow you to:

- Scan and detect non-optimal video files
- Convert videos (or entire libraries) into a Jellyfin-friendly format
- Minimize transcoding load on your media server
- Standardize old or inconsistent video collections

## Requirements

- ffmpeg installed

---

## Included Tools

### **1. jellyfin-no-transcode-check.sh**

Analyzes a single video or directory and reports whether the files will play without transcoding in Jellyfin.

Example:

```sh
./jellyfin-no-transcode-check.sh video.mkv
```

### **2. jellyfin-transcode-optimize.sh**

Converts video files to the recommended Jellyfin-friendly format.

Example (single file):

```sh
./jellyfin-transcode-optimize.sh video.mkv
```

Recursive conversion:

```sh
./jellyfin-transcode-optimize.sh -r ~/Videos/
```

Options:

<pre>
  -r       Convert files recursivly.
  -d       Remove input file after convert.
  -c       Set custom frame rate.
  -h       Show options.
</pre>

## Define linux alias

To use script as a linux console command make the following:

- open .bashrc

```sh
vi ~/.bashrc
```

- add following lines and set correct path to the script files:

```sh
alias jfcheck='/path/to/jellyfin-no-transcode-check.sh'
alias jfconvert='/path/to/jellyfin-transcode-optimize.sh'
```

- restart the console

## License

Copyright 2021 Boguslaw Proszkowiec

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
