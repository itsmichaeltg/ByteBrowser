import sys
import os
from dotenv import load_dotenv, dotenv_values
from openai import OpenAI

path_to_write_to = "/home/ubuntu/jsip-final-project/bin/query_answer.txt"
path_to_read_for_query_prompt = "/home/ubuntu/jsip-final-project/bin/query_prompt.txt"
path_to_read_for_query_info = "/home/ubuntu/jsip-final-project/bin/query_info.txt"

load_dotenv()

if __name__ == "__main__":
    client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
    prompt_file, info_file = open(path_to_read_for_query_prompt, "r"), open(
        path_to_read_for_query_info, "r"
    )
    info, prompt = info_file.read(), prompt_file.read()
    info_file.close(), prompt_file.close()
    completion = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {
                "role": "system",
                "content": "you are an assitant file manager. succinctly answer the questions of the user on the provided contents.\n"
                + f"here is the information:\n{info}",
            },
            {"role": "user", "content": prompt},
        ],
    )
    file_to_write = open(path_to_write_to, "a")
    file_to_write.write("")
    file_to_write.write(completion.choices[0].message.content)
    file_to_write.close()
