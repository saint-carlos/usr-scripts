#!/usr/bin/env python3

import argparse
import sys
import os

PROG_DESC = 'Translate between ASCII numbers and their ASCII codes.'
PROG_VERSION = 'ascii 2.0'

def cbyte(n):
    return bytes([n])

NONSTANDARD_PLACEHOLDER = 0xff
NONSTANDARD_PLACEHOLDER_CHR = chr(NONSTANDARD_PLACEHOLDER)
NONSTANDARD_PLACEHOLDER_BYTE = cbyte(NONSTANDARD_PLACEHOLDER)

parser = argparse.ArgumentParser(description=PROG_DESC,
        formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument('-V', '--version',
        action='version', version=PROG_VERSION)
parser.add_argument('-a', '--to-char',
        dest='function', action='store_const', const='to_char',
        help='''read ASCII codes and print them out as ASCII characters,
instead of the other way around.''')
parser.add_argument('-1', '--from-char',
        dest='function', action='store_const', const='from_char',
        help='read ASCII characters and print them out as ASCII codes (default).')
parser.add_argument('-x', '--hexadecimal',
        dest='decimal', action='store_false',
        help='read/write ASCII codes as hexadecimal instead of decimal.')
parser.add_argument('-d', '--decimal',
        dest='decimal', action='store_true',
        help='read/write ASCII codes as decimal.')
parser.add_argument('--special-chars',
        dest='special_chars', choices=['raw', 'short', 'long'], default='raw',
        help='''how to emit special characters:
raw: emit the character as is.
long: emit descriptive name, e.g. ["backspace"].
short: emit a mnemonic, e.g. [BS] for backspace.''')
parser.add_argument('-s', '--short-special-chars',
        dest='special_chars', action='store_const', const='short',
        help='equivalent to --special-chars short')
parser.add_argument('-S', '--long-special-chars',
        dest='special_chars', action='store_const', const='long',
        help='equivalent to --special-chars long')
parser.add_argument('-l', '--list-special',
        dest='function', action='store_const', const='list_special',
        help='list the known special characters and exit.')
parser.add_argument('-t', '--table',
        dest='function', action='store_const', const='table',
        help='display ascii table and exit.')
parser.add_argument('-T', '--table-all', '--list-all',
        dest='function', action='store_const', const='table_all',
        help='display full ascii table (0-255) and exit.')
parser.add_argument('-p', '--print-nonstandard',
        dest='print_nonstandard', action='store_true',
        help='''print non-standard characters (of a value 128 or higher) raw
instead of just a placeholder.
this may not work correctly or as expected when the output is the terminal,
depending on your terminal. your terminal may also choose to print nonstandard
characters as placeholders regardless of this flag.''')
parser.add_argument('--no-print-nonstandard',
        dest='print_nonstandard', action='store_false',
        help=f'''replace non-standard characters (of a value 128 or higher) with
a placeholder (with ascii code {NONSTANDARD_PLACEHOLDER}, which is '{NONSTANDARD_PLACEHOLDER_CHR}' (default).''')
parser.add_argument('-n', '--no-newline',
        dest='newline', action='store_false',
        help='do not append a newline after processing input.')
parser.add_argument('arg', nargs='*', type=os.fsencode,
        help='the string to be translated. if not given, read from stdin.')

def parse_args():
    args = parser.parse_args()
    if args.function is None:
        args.function = 'from_char'
    if args.newline is None:
        args.newline = True
    return args

def buf_to_str(buf):
    return buf.decode('raw_unicode_escape')

def str_to_buf(s):
    return s.encode('ascii')

fmttab_dec = []
fmttab_hex = []

rfmttab_dec = {}
rfmttab_hex = {}

def init_fmttab():
    global fmttab_dec
    global fmttab_hex
    global rfmttab_dec
    global rfmttab_hex
    for n in range(0, 256):
        decstr = " {}".format(n)
        hexstr = " {:x}".format(n)
        hexzstr = "{:02x}".format(n)
        fmttab_dec.append(str_to_buf(decstr))
        fmttab_hex.append(str_to_buf(hexstr))
        rfmttab_dec[decstr[1:]] = n
        rfmttab_hex[hexstr[1:]] = n
        rfmttab_hex[hexzstr] = n

class NumFormat:
    def __init__(self, base):
        self.base = base
        if base == 10:
            self.fmttab = fmttab_dec
            self.rfmttab = rfmttab_dec
        elif base == 16:
            self.fmttab = fmttab_hex
            self.rfmttab = rfmttab_hex
        self.fmt = lambda n: self.fmttab[n]

    def from_str(self, s):
        try:
            n = self.rfmttab[s]
            return n
        except:
            return None

    def to_str(self, n):
        return self.fmt(n)[1:]

    def get_to_str_prespaced(self):
        return self.fmt

def set_number_format(ctx):
    init_fmttab()
    base = 10 if ctx.cfg.decimal else 16
    ctx.num_format = NumFormat(base)

special_chars = {
    0x00: [ "NUL",  "null"                  ],
    0x01: [ "SOH",  "start of heading"      ],
    0x02: [ "STX",  "start of text"         ],
    0x03: [ "ETX",  "end of text"           ],
    0x04: [ "EOT",  "end of transmit"       ],
    0x05: [ "ENQ",  "enquiry"               ],
    0x06: [ "ACK",  "positive acknowledge"  ],
    0x07: [ "BEL",  "bell"                  ],
    0x08: [ "BS" ,  "backspace"             ],
    0x09: [ "HT" ,  "horizontal tab"        ],
    0x0a: [ "LF" ,  "line feed"             ],
    0x0b: [ "VT" ,  "vertical tab"          ],
    0x0c: [ "FF" ,  "form feed"             ],
    0x0d: [ "CR" ,  "carriage return"       ],
    0x0e: [ "SO" ,  "shift out"             ],
    0x0f: [ "SI" ,  "shift in"              ],
    0x10: [ "DLW",  "data link escape"      ],
    0x11: [ "DC1",  "device control 1"      ],
    0x12: [ "DC2",  "device control 2"      ],
    0x13: [ "DC3",  "device control 3"      ],
    0x14: [ "DC4",  "device control 4"      ],
    0x15: [ "NAK",  "negative acknowledge"  ],
    0x16: [ "SYM",  "synchronous idle"      ],
    0x17: [ "ETB",  "end of transmit block" ],
    0x18: [ "CAN",  "cancel"                ],
    0x19: [ "EM" ,  "end of medium"         ],
    0x1a: [ "SUB",  "substitute"            ],
    0x1b: [ "ESC",  "escape"                ],
    0x1c: [ "PS" ,  "file separator"        ],
    0x1d: [ "GS" ,  "group separator"       ],
    0x1e: [ "RS" ,  "record separator"      ],
    0x1f: [ "US" ,  "unit separator"        ],
    0x7f: [ "DEL",  "delete"                ]
}

def mk_special_chars_table(prefix, column, postfix):
    global special_chars
    res = {}
    for k, v in special_chars.items():
        s = prefix + v[column] + postfix
        res[k] = str_to_buf(s)
    return res

def special_chars_table(special_chars_cfg):
    if special_chars_cfg == 'short':
        return mk_special_chars_table('[', 0, ']')
    elif special_chars_cfg == 'long':
        return mk_special_chars_table('["', 1, '"]')
    else:
        return None

def is_nonstandard_char(n):
    return n >= 128

def is_special_char(n):
    return n < 32 or n == 127

def list_chars(types):
    global special_chars
    print('Dec\tHex\tShort\tLong')
    for n in range(0, 256):
        c = buf_to_str(cbyte(n))
        short_str = None
        if is_special_char(n):
            if 'special' in types:
                short_str = special_chars[n][0]
                long_str = special_chars[n][1]
        elif is_nonstandard_char(n):
            if 'nonstandard' in types:
                short_str = c
                long_str = NONSTANDARD_PLACEHOLDER_CHR
        else:
            if 'regular' in types:
                short_str = c
                long_str = c
        if short_str is not None:
            print('{dec:3d}\t{hex:02x}\t{short}\t{long}'.format(
                dec=n,
                hex=n,
                short=short_str,
                long=long_str
            ))

def set_char_emitter(ctx):
    transform_special = ctx.cfg.special_chars != 'raw'
    transform_nonstandard = not ctx.cfg.print_nonstandard
    table = special_chars_table(ctx.cfg.special_chars)

    chartab = []
    for n in range(0, 256):
        if transform_special and is_special_char(n):
            b = table[n]
        elif transform_nonstandard and is_nonstandard_char(n):
            b = NONSTANDARD_PLACEHOLDER_BYTE
        else:
            b = cbyte(n)
        chartab.append(b)

    def emit_chr(n):
        return chartab[n]

    ctx.emit_chr = emit_chr

class Input:
    def __init__(self, num_format, ctx):
        self.num_format = num_format
        self.ctx = ctx

    def token_to_num(self, token):
        n = self.num_format.from_str(token)
        if n is None:
            print(token + ";", file=sys.stderr, end='')
            self.ctx.err = 1
            return None
        else:
            return n

    def next_number(self):
        while True:
            next_token = self.next_token()
            if not next_token:
                return None
            n = self.token_to_num(next_token)
            if n is not None:
                return n

class ArgInput(Input):
    def __init__(self, args, num_format, ctx):
        super().__init__(num_format, ctx)
        self.args = args
        self.next = 0

    def next_token(self):
        buf = self.next_buf()
        if not buf:
            return None
        return buf_to_str(buf)

    def next_buf(self):
        current = self.next
        if current >= len(self.args):
            return None
        self.next += 1
        return self.args[current]

class StreamInput(Input):
    def __init__(self, num_format, ctx):
        super().__init__(num_format, ctx)
        self.instream = sys.stdin
        self.next_array = None
        self.next_idx = 0

    def next_token(self):
        if not self.next_array:
            s = self.instream.read()
            if not s:
                return None
            self.next_array = s.split()
            self.next_idx = 0
        res = self.next_array[self.next_idx]
        self.next_idx += 1
        if self.next_idx >= len(self.next_array):
            self.next_array = None
        return res

    def next_buf(self):
        buf = self.instream.buffer.read()
        if not buf:
            return None
        return buf

def set_input(ctx):
    if ctx.cfg.arg:
        ctx.input = ArgInput(ctx.cfg.arg, ctx.num_format, ctx)
    else:
        ctx.input = StreamInput(ctx.num_format, ctx)

def emit_optional_newline(ctx):
    if ctx.cfg.newline and ctx.has_output:
        print()

def to_char(ctx):
    while True:
        n = ctx.input.next_number()
        if n is None:
            break
        b = ctx.emit_chr(n)
        sys.stdout.buffer.write(b)
        ctx.has_output = True
    emit_optional_newline(ctx)

def from_char(ctx):
    to_str_prespaced = ctx.num_format.get_to_str_prespaced()
    first_str = True
    while True:
        buf = ctx.input.next_buf()
        if buf is None:
            break

        if not first_str:
            sys.stdout.buffer.write(b' ')
        first_str = False

        sys.stdout.buffer.write(ctx.num_format.to_str(buf[0]))
        for b in buf[1:]:
            sys.stdout.buffer.write(to_str_prespaced(b))
        ctx.has_output = True

    emit_optional_newline(ctx)

def list_special(ctx):
    list_chars(['special'])

def table(ctx):
    list_chars(['regular', 'special'])

def table_all(ctx):
    list_chars(['regular', 'special', 'nonstandard'])

def invoke(s, *args, **kwargs):
    f = getattr(sys.modules[__name__], s)
    f(*args, **kwargs)

class Ctx:
    pass
ctx = Ctx()

ctx.cfg = parse_args()
ctx.has_output = False
ctx.err = 0

set_number_format(ctx)
set_char_emitter(ctx)
set_input(ctx)
invoke(ctx.cfg.function, ctx)
sys.exit(ctx.err)
