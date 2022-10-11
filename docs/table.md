### ezb_table_print
```shell
$ ezb_table_print --col-delimiter "," --row-delimiter ";" --data "head1,head2,head3;,,x;y,z,;,123,;a,,;,ab,c;1,2,3"
+--------+--------+--------+
| head1  | head2  | head3  |
+--------+--------+--------+
|        |        | x      |
| y      | z      |        |
|        | 123    |        |
| a      |        |        |
|        | ab     | c      |
| 1      | 2      | 3      |
+--------+--------+--------+

```