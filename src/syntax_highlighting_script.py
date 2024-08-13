home_dir = os.getenv('HOME')
path_to_read_code_from = (
    home_dir + "/ByteBrowser/bin/code_to_be_highlighted.txt"
)
path_to_write_to =  home_dir + "/ByteBrowser/bin/highlighted_code.txt"
path_to_read_file_path_from =  home_dir + "/ByteBrowser/bin/path_to_preview.txt"

from pygments import highlight
from pygments.lexers import get_lexer_for_filename
from pygments.lexers.ml import OcamlLexer
from pygments.formatters import Terminal256Formatter

if __name__ == "__main__":
    file_path_file = open(path_to_read_file_path_from, "r")
    file_path_contents = file_path_file.read()
    file_path_file.close()
    code_file = open(path_to_read_code_from, "r")
    code_file_contents = code_file.read()
    code_file.close()
    try:
        lexer = get_lexer_for_filename(file_path_contents)
    except:
        lexer = OcamlLexer()
    file_to_write_to = open(path_to_write_to, "w")
    style = "one-dark" if file_path_contents == "" else "staroffice"
    highlight(
        code_file_contents,
        lexer,
        Terminal256Formatter(style=style),
        file_to_write_to,
    )
    file_to_write_to.close()
