### ez.time.elapsed
```shell
$ ez.time.elapsed --start "2022-09-27 01:20:35" --end "2022-09-27 03:40:45"
2h20m10s
$ ez.time.elapsed --start "2022-09-28 01:20:35" --end "2022-09-27 03:40:45"
-21h39m50s

$ format="%m/%d/%Y %H:%M:%S"
$ start=$(date "+${format}"); sleep 90; end=$(date "+${format}")
$ ez.time.elapsed -s "${start}" -e "${end}" -f "${format}"
1m30s
```
### ez.time.offset
```shell
$ ez.time.offset --timestamp "2022-09-27 01:20:35" --unit days --offset -5
2022-09-22 01:20:35
$ ez.time.offset -t "2022-09-27 01:20:35" -u days -o 7
2022-10-04 01:20:35
$ ez.time.offset -t "2022-09-27 01:20:35" -u minutes -o 55
2022-09-27 02:15:35
$ ez.time.offset -t "2022-09-27 01:20:35" -u seconds -o -55
2022-09-27 01:19:40
$ ez.time.offset -t "09/27/2022 01:20:35" -u hours -o -3 -f "%m/%d/%Y %H:%M:%S"
09/26/2022 22:20:35
$ ez.time.offset -t "09/27/2022 01:20:35" -u hours -o 24 -f "%m/%d/%Y %H:%M:%S"
09/28/2022 01:20:35
```