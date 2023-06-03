# Fine-tuning

A simple example of fine-tuning an [ada](https://platform.openai.com/docs/models) model. I want my model to answer the question on which continent a
specific country is located.

### Step #1: OPENAI_API_KEY

Set your OPENAI_API_KEY in `.env` file.

### Step #2: Docker

Build an image from a Dockerfile
``docker build -t fine_tuning_image .``
and run a container ``docker run -it —rm --env-file .env --name fine_tuning_container fine_tuning_image``

### Step #3: Data

Once you are inside the container, create a directory `mkdir app` and enter it `cd app/`. Download the file containing the list of countries and their
corresponding continents.

```shell
wget https://raw.githubusercontent.com/samayo/country-json/master/src/country-by-continent.json -O countries.json
```

Prepare the data with a PHP script `vim prepare.php`.

```php
<?php
$data = json_decode(file_get_contents('countries.json'));

foreach($data as $item)
        echo json_encode([
                'prompt' => "On which continent is $item->country?\n\n###\n\n",
                'completion' => "$item->continent\n"
        ])."\n";
```

Save the data to a JSON file `php prepare.php >data.json` and perform final data preparation using the OpenAI tool.

```shell
openai tools fine_tunes.prepare_data -f data.json
```

The tool will ask some additional questions

```shell
Based on the analysis we will perform the following actions:
- [Necessary] Your format `JSON` will be converted to `JSONL`
- [Recommended] Remove prefix `On which continent is ` from all prompts [Y/n]: n
- [Recommended] Add a whitespace character to the beginning of the completion [Y/n]: y
- [Recommended] Would you like to split into training and validation set? [Y/n]: n


Your data will be written to a new JSONL file. Proceed [Y/n]: y
```

to finally generate a `data_prepared.jsonl` file that will be used for fine-tuning.

### Step #4: Fine-tuning

Even the **ada** model will meet such simple requirements:

```shell
openai api fine_tunes.create -t "data_prepared.jsonl" -m ada
```

After executing the above command, the training of the model will start. Its status can be checked with the command:

```shell
openai api fine_tunes.get -i ft-XXXXXXXXXXXXXXXXXXXX | grep -i status
```

Read more about fine-tuning on https://platform.openai.com/docs/guides/fine-tuning.

### Step #5: Playground

On the [Playground](https://platform.openai.com/playground?mode=complete) website, we can check the result of our training. Don't forget to set a new model and
set `###` as _**Stop sequences**_.
![Playground](https://raw.github.com/cichy380/fine-tuning-openai/main/finetuning.png)
