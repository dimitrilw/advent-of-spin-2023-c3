# advent-of-spin-2023-c3

Fermyon advent-of-spin 2023, challenge 3

Visit this repo's [webpage](https://aos3.fermyon.app/) for a live demo in your browser.

## Components

### fs

Simple filesystem access, for serving files in `/assets` directory. Example:
`aos3.fermyon.app/index.html` will return the file `assets/index.html`.

### APIs

Multiple API endpoints were created to experiment with different languages.
Each of the entry APIs receive and return the same JSON template.

#### stand-alone, single-language APIs

Each of these APIs is a single component, in a single file.

##### rust-api

`/rust-api/src/main.rs`, which contains all logic for a simple REST API,
written in Rust, and initiated with Spin's `http-rust` template.

##### go-api

`/go-api/main.go`, which contains all logic for a simple REST API,
written in Go, and initiated with Spin's `http-go` template.

##### py-api

`/py-api/main.py`, which contains all logic for a simple REST API,
written in Python, and initiated with Spin's `http-py` template.

#### complex, multi-language APIs

##### hybrid-api

```diff
--- IN DEVELOPMENT ---
```

The `/hybrid-api` endpoint is really a blend of three Spin components,
each written in a different language, and each with a different purpose.

The `/hybrid-api` endpoint is a simple REST API, written in Rust.
It receives a JSON object, then it calls the `/hybrid-api/llm` endpoint.
`/hybrid-api/llm` is the handler for interactions with the LLM, but before
each interaction, it calls the `/hybrid-api/prompt` endpoint to transform
the initial JSON object into a prompt for the LLM.

`/hybrid-api/llm` is a simple REST API, written in Go.

`/hybrid-api/prompt` is a simple REST API, written in Python.

##### composed-api

```diff
--- IN DEVELOPMENT ---
```

The `/composed-api` endpoint is the same overall logic as the `/hybrid-api`;
however, instead of using three separate Spin components,
it uses the Bytecode Alliance's Component Model to compose the three
WASM binaries into a single binary, even though the source is three different
languages: Rust, Go, and Python.

<hr/>

Text below is from the [Fermyon repo for 2023 challenge 3][c3repo], with minor edits.

[c3repo]: https://github.com/fermyon/advent-of-spin/tree/main/2023/Challenge-3

<hr/>

## Spec

The elves have noticed that we're suddenly almost half-way through advent,
so things are becoming a bit hectic. One of things the storyteller-elves suddenly realized,
is that they haven't started writing the new Christmas stories for this year.

The elves will need your help in "writing" the most exciting and engaging christmas story
of the year. Luckily they have discovered the Serverless AI features of Spin,
and they think that might be a good way of doing this.

You can write your application in ANY language that compiles to WebAssembly.
To skip the boilerplate, use `spin new` and use one of our language templates.

The elves will use you a random set of words, as inspiration to your story,
now it's up to you to figure out how you can prompt the LLMs to use those words
to create the most engaging christmas story. Hint: You can try to do a specific kind
of style for your story (poem, play, short-story), Who's the narrator?,
What's the language like (funny, sad, Simpsons-like)?

The elves will POST to `/` with a JSON object like this (sample data):

```JSON
{
    "place": "North Pole",
    "characters": ["Santa Claus", "The Grinch", "a penguin"],
    "objects": ["A spoon", "Two presents", "Palm tree"]
}
```

There are no requirements as to how long or short the story can be.

- When posting, the elves expect an HTTP status code `200` to be returned. With the following body:

```JSON
{
    "story": "<YOUR STORY HERE>"
}
```

- Also the header in the response should contain `Content-Type: application/json`

> Note: The above data is an example, the data used when submitting will be different values.

## Test

You can run our [Hurl](https://hurl.dev) test suite with `hurl --test test.hurl`,
which will carry out tests, similar to what the elves will use you application for,
when you submit it. Ensure you have `hurl` [installed](https://hurl.dev/docs/installation.html).

## Submit

Once the application is deployed, enter the endpoint as serviceUrl below
and run the command - e.g., `https://x-mas.fermyon.app`

> Note: Do not add a trailing `/` to the serviceUrl.

```shell
hurl --error-format long --variable serviceUrl="https://x-mas.fermyon.app" submit.hurl
```

Remember, if you want to participate in the swag award, go [here](../../README.md#Prizes)
and check out how to participate.

## Nobody Must Code Alone

Please don't hesitate to reach out to the elves on Fermyon [Discord](https://discord.gg/AAFNfS7NGf)
server if you have any questions, they may be busy this time a year,
but they are always ready to help and answer questions. This is a great opportunity
to meet others in the community as well. We’ll also post on
[X/Twitter](https://twitter.com/fermyontech) and
[LinkedIn](https://www.linkedin.com/company/fermyon), dropping some helpful resources and videos.

Remember there are prizes for each challenge. So it may be you,
to whom the elves will deliver a nice award to.

Note: If you submit using Fermyon Cloud, we will contact you for any awards you may win.
If you aren't using the Fermyon cloud to host your application,
please reach out to the elves on Fermyon
[Discord](https://discord.gg/AAFNfS7NGf) to register your submission
