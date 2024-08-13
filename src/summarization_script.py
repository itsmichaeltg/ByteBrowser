import sys
import os
from dotenv import load_dotenv, dotenv_values
from openai import OpenAI

path_to_write_to = "~/ByteBrowser/bin/completion.txt"
path_to_read_from = "~/ByteBrowser/bin/file_contents.txt"

load_dotenv()

if __name__ == "__main__":
    client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
    file = open(path_to_read_from, "r")
    file_contents = file.read()
    file.close()
    completion = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {
                "role": "system",
                "content": "you are an assitant file manager. succinctly summarize the contents of the file contents of a directory of files or a single file.",
            },
            {"role": "user", "content": file_contents},
        ],
    )
    file_to_write = open(path_to_write_to, "a")
    file_to_write.write("")
    file_to_write.write(completion.choices[0].message.content)
    file_to_write.close()
