# Test how many present can be in Santa's sack, when he has to travel the least
# Please note, that we will a different set of numbers when validating your submission

#POST https://aos3.fermyon.app/rust-api

POST http://localhost:3000/py-api
{
    "place": "North Pole",
    "characters": ["Santa Claus", "The Grinch", "a penguin"],
    "objects": ["A spoon", "Two presents", "Palm tree"]
}

HTTP 200
[Asserts]
jsonpath "$.story" != null