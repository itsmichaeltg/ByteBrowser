path_to_read_from = "/home/ubuntu/jsip-final-project/bin/code_to_be_highlighted.txt"
path_to_write_to = "/home/ubuntu/jsip-final-project/bin/highlighted_code.txt"

from pygments import highlight
from pygments.lexers import get_lexer_for_filename
from pygments.formatters import Terminal256Formatter
import sys

if __name__ == "__main__":
    file_name = sys.argv[0]
    code_file = open(path_to_read_from, "r")
    code_file_contents = code_file.read()
    code_file.close()
    lexer = get_lexer_for_filename(file_name)
    file_to_write_to = open(path_to_write_to, "w")
    highlight(code_file_contents, lexer, Terminal256Formatter(style='monokai'), file_to_write_to)
    file_to_write_to.close()
