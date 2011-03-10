package Zabbix::Utils;

use parent 'Exporter';

our @EXPORT_OK = qw($RE_FORMULA);

# TODO: rendre les guillemets optionnels, support de plusieurs function_args
our $RE_FORMULA =
    qr/(?<function_call>[\w]+\(
         (?<function_args>"
           (?<host>[\w .]+)
           :
           (?<item>[\w.]+)
           \[
             (?<item_arg>(\w+)(,(\w+))*)
             (,
               (?<item_arg>(\w+)(,(\w+))*)
             )*
           \]
         ")
       \))/x;
