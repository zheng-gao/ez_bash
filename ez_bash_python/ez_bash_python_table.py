import argparse
import csv
from prettytable import PrettyTable


def string_to_bool(input_string):
    if input_string.lower() in ('yes', 'true', 't', 'y', '1'):
        return True
    elif input_string.lower() in ('no', 'false', 'f', 'n', '0'):
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')


def convert_type(type_name, input_string):
    if type_name == "int":
        return int(input_string)


PARSER = argparse.ArgumentParser(description="Read and Print Table")
PARSER.add_argument("--input-file", dest="input_file", required=True)
PARSER.add_argument("--encoding", dest="encoding", default="utf-8", choices=["utf-8", "latin9"])
PARSER.add_argument("--row-delimiter", dest="row_delimiter", default="\n", help="Row Delimiter")
PARSER.add_argument("--col-delimiter", dest="col_delimiter", default="\t", help="Column Delimiter")
PARSER.add_argument("--table-fields", dest="table_fields", default=None, help="Treat the 1st row as fields if this argument is not given")
PARSER.add_argument("--fields-type", dest="fields_type", default=None, help="[index_1:type_1,index_2:type_2,...] 1:int,2:float,... by default treat all field as string")
PARSER.add_argument("--sort-by", dest="sort_by", default=None, help="Sort by field name")
PARSER.add_argument("--reverse-sort", type=string_to_bool, dest="reverse_sort", nargs='?', const=True, default=False, help="Reverse Sort")
ARGUMENTS = PARSER.parse_args()


def main(args):
    row_delimiter=args.row_delimiter.replace("\\n", "\n")
    col_delimiter=args.col_delimiter.replace("\\t", "\t")
    if args.table_fields is not None:
        args.table_fields = args.table_fields.replace("\\t", "\t")
    fields_type_dict = dict()
    if args.fields_type is not None:
        for field_type in args.fields_type.split(','):
            field_index, field_type = field_type.split(':')
            fields_type_dict[int(field_index)] = field_type
    table = PrettyTable()
    with open(args.input_file, encoding=args.encoding, mode="r", newline=row_delimiter) as file_handler: 
        reader = csv.reader(file_handler, delimiter=col_delimiter, lineterminator=row_delimiter, strict=True)
        if args.table_fields is None:
            table.field_names = next(reader)
        else:
            table.field_names = args.table_fields.split(col_delimiter)
        for row in reader:
            table_row = list()
            for index, value in enumerate(row):
                table_field_index = index + 1
                if table_field_index in fields_type_dict:
                    table_value = convert_type(type_name=fields_type_dict[table_field_index], input_string=value.strip())
                else:
                    table_value = value.strip()
                table_row.append(table_value)
            table.add_row(table_row)
    # Set the columns to left justified.
    table.align = "l"
    # Set the row to top justified.
    table.valign = "t"
    # Print table
    if args.sort_by is not None:
        print(table.get_string(sortby=args.sort_by, reversesort=args.reverse_sort))
    else:
        print(table)


if __name__ == "__main__":
    main(args=ARGUMENTS)