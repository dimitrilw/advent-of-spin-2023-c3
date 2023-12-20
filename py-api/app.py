# reminder: the `type: ignore` notation is to prevent Pylance from complaining about
#           the import statements; it doesn't know about the vendored dependencies

from spin_http import Response # type: ignore
from spin_llm import llm_infer # type: ignore
import json
import time
import random

def build_prompt(options):
    additional_characters = ", ".join(options["characters"])
    objects = ", ".join(options["objects"])
    return " ".join([
        "please generate a winter holiday story that:",
        "references the Python programming language and/or snakes;",
        f"and takes place at {options['place']};",
        f"and contains these characters: a bunny, {additional_characters};",
        f"and references these objects: {objects};",
        f"and is written in the style of {options['style']};",
        "and is limited to 500 words.",
    ])

def pick_random_style():
    # TODO: can I have the file embedded in the function (like I did with both Go & Rust)
    #       instead of retrieving from URL? Have done this before by pickling the file,
    #       but I'd like to avoid that if possible; lot of manual work to keep it up to date.
    #       ...perhaps this?
    #           https://stackoverflow.com/questions/39337630/embedding-resources-in-python-scripts
    #       In the meantime, I'm just doing copy-pasta (ick) to keep things moving.

    return random.choice([
        "the book A Christmas Carol by Charles Dickens",
        "the book How the Grinch Stole Christmas by Dr. Seuss",

        "the poem A Visit from St. Nicholas by Clement Clarke Moore",

        "the screenplay for the movie Elf",
        "the screenplay for the movie Home Alone",
        "the screenplay for the movie It's a Wonderful Life",
        "the screenplay for the movie Die Hard",
        "the screenplay for the movie National Lampoon's Christmas Vacation",
        "the screenplay for the movie A Christmas Story",
        "the screenplay for the movie The Nightmare Before Christmas",

        "the song White Christmas",
        "the song Jingle Bells",
        "the song Rudolph the Red-Nosed Reindeer",
        "the song Frosty the Snowman",
        "the song Santa Claus is Coming to Town",
        "the song I Saw Mommy Kissing Santa Claus",
        "the song All I Want for Christmas is You by Mariah Carey",
        "the song Do They Know It's Christmas? by Band Aid",
        "the song All I Really Want for Christmas by Lil Jon",
    ])

def handle_request(request):
    try:
        start = time.time_ns()

        data = json.loads(request.body)

        print("py-api, data:", data)

        if "style" not in data or data["style"] == "":
            data["style"] = pick_random_style()

        prompt = build_prompt(data)

        result = llm_infer("llama2-chat", prompt)

        payload = json.dumps({
            "story": result.text,
            "style": data.get("style", "ERROR: style not specified"),
            "ns": time.time_ns() - start,
        })

        print("py-api, payload:", payload)

        return Response(200, {"content-type": "application/json"}, bytes(payload, "utf-8"))
    except Exception as e:
        print("py-api, error:", e)
        return Response(500, {"content-type": "text/plain"}, bytes(f"Error: {str(e)}", "utf-8"))