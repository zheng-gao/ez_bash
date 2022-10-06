### ezb_calculate
```shell
$ ezb_calculate --expression "1 + 2*3 / (2.5 - 0.5)" --scale 3
4.000
```

### ezb_floor & ezb_ceiling
```shell
$ {
    echo "Number Floor Ceiling"
    for x in 0.0 5.6 0.3 2.0 -1.7; do
        echo "$x $(ezb_floor $x) $(ezb_ceiling $x)"
    done
} | column -t
Number  Floor  Ceiling
0.0     0      0
5.6     5      6
0.3     0      1
2.0     2      2
-1.7    -2     -1
```

### ezb_min & ezb_max
```shell
$ data=(3 5 1 0 2 0 3); echo "min: $(ezb_min ${data[@]}), max: $(ezb_max ${data[@]})"
min: 0, max: 5
```

### ezb_sum & ezb_average
```shell
$ data=(3 5 1 0 2 0 3); echo "sum: $(ezb_sum ${data[@]}), average: $(ezb_average -d ${data[@]} -s 2)"
sum: 14, average: 2.00
```

### ezb_variance & ezb_std_deviation
```shell
$ data=(3 5 1 0 2 0 3); echo "variance: $(ezb_variance -d ${data[@]}), std_deviation: $(ezb_std_deviation -d ${data[@]})"
variance: 3.333333, std_deviation: 1.825741
```

### ezb_percentile
```shell
$ data=(1 2 3 4 5 6 7 8 9 10)
$ percentiles=(0 5 10 25 50 66 70 75 83 90 95 99 100)
$ methods=("Linear" "Lower" "Higher" "Midpoint" "Nearest")
$ {
      echo "Percentile ${methods[@]}"
      for p in "${percentiles[@]}"; do
          line="P${p}"
          for m in "${methods[@]}"; do
              value=$(ezb_percentile --data "${data[@]}" --percentile "${p}" --method "${m}" --scale 2)
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


