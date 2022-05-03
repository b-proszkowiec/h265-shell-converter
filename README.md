H265 command line video converter
=======================

Easy to use script to compress given video to modern and high efficiency h265 standard. It uses ffmpeg program and makes possible to convert all files of your video library with a single command. It reduces library size on the computer without losing its quality.


Requirements
-----
- Linux operation system
- ffmpeg installed

Usage
-----

You can run the script with the following options:
<pre>
  -r       Convert files recursivly.
  -d       Remove input file after convert.
  -c       Set custom frame rate.
  -h       Show options.
</pre>

Define linux alias
-----

To use script as a linux console command make the following:

- open .bashrc
````sh
vi ~/.bashrc
````

- add following line to the file and modify location of `hevc.sh`
````sh
alias hevc='~/repo/h265-shell-converter/hevc.sh'
````
- restart the console

License
-----

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