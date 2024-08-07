### ez.calculate
```shell
$ ez.calculate --expression "1 + 2*3 / (2.5 - 0.5)" --scale 3
4.000
```

### ez_floor & ez_ceiling
```shell
$ {
    echo "Number Floor Ceiling"
    for x in 0.0 5.6 0.3 2.0 -1.7; do
        echo "$x $(ez_floor $x) $(ez_ceiling $x)"
    done
} | column -t
Number  Floor  Ceiling
0.0     0      0
5.6     5      6
0.3     0      1
2.0     2      2
-1.7    -2     -1
```

### ez_decimal_to_base_x
```shell
$ for i in {0..8}; do echo -n "BIN(${i}): "; ez_decimal_to_base_x --decimal $i --base 2 --padding 4; done
BIN(0): 0000
BIN(1): 0001
BIN(2): 0010
BIN(3): 0011
BIN(4): 0100
BIN(5): 0101
BIN(6): 0110
BIN(7): 0111
BIN(8): 1000

$ for i in {28..36}; do echo -n "OCT(${i}): "; ez_decimal_to_base_x --decimal $i --base 8; done
OCT(28): 34
OCT(29): 35
OCT(30): 36
OCT(31): 37
OCT(32): 40
OCT(33): 41
OCT(34): 42
OCT(35): 43
OCT(36): 44

$ for i in {28..36}; do echo -n "HEX(${i}): "; ez_decimal_to_base_x --decimal $i --base 16; done
HEX(28): 1c
HEX(29): 1d
HEX(30): 1e
HEX(31): 1f
HEX(32): 20
HEX(33): 21
HEX(34): 22
HEX(35): 23
HEX(36): 24
````

### ez_min & ez_max
```shell
$ data=(3 5 1 0 2 0 3)
$ echo "min: $(ez_min ${data[@]}), max: $(ez_max ${data[@]})"
min: 0, max: 5
```

### ez_sum & ez_average
```shell
$ data=(3 5 1 0 2 0 3)
$ echo "sum: $(ez_sum ${data[@]}), average: $(ez_average -d ${data[@]} -s 2)"
sum: 14, average: 2.00
```

### ez_variance & ez_std_deviation
```shell
$ data=(3 5 1 0 2 0 3)
$ echo "variance: $(ez_variance -d ${data[@]}), std_deviation: $(ez_std_deviation -d ${data[@]})"
variance: 3.333333, std_deviation: 1.825741
```

### ez_percentile
```shell
$ data=(1 2 3 4 5 6 7 8 9 10)
$ percentiles=(0 5 10 25 50 66 70 75 83 90 95 99 100)
$ methods=("Linear" "Lower" "Higher" "Midpoint" "Nearest")
$ {
      echo "Percentile ${methods[@]}"
      for p in "${percentiles[@]}"; do
          line="P${p}"
          for m in "${methods[@]}"; do
              value=$(ez_percentile --data "${data[@]}" --percentile "${p}" --method "${m}" --scale 2)
              line+=" ${value}"
          done
          echo "${line}"
      done
  } | column -t

Percentile  Linear  Lower  Higher  Midpoint  Nearest
P0          1       1      1       1         1
P5          1.45    1      2       1.50      1
P10         1.90    1      2       1.50      2
P25         3.25    3      4       3.50      3
P50         5.50    5      6       5.50      5
P66         6.94    6      7       6.50      7
P70         7.30    7      8       7.50      7
P75         7.75    7      8       7.50      8
P83         8.47    8      9       8.50      8
P90         9.10    9      10      9.50      9
P95         9.55    9      10      9.50      10
P99         9.91    9      10      9.50      10
P100        10      10     10      10        10
```


