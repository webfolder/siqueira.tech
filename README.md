# About Scaffold

## Add images with caption to your posts

> Use the following include in your markdown:

```
{% include image-post.html path="PATH_RELATIVE_TO_images" caption="ANY TEXT" %}
```

> Keep in mind that you have to add the path relative to the directory "images"

## Add youtube video

> Use:

```
{% include youtube-player.html id="EMBEDED_CODE_PROVIDED_BY_YOUTUBE" %}
```

> Note that you does not need to add the full url, just add the code. See the
example below:

```
{% include youtube-player.html id="Q1cmhZs1P54" %}
```

## Add Item to a list

```
./scaffold/add_item.sh --target=<TARGET_LIST> --name=<THE_NAME_YOU_WANT> --image=<AN_IMAGE_IN_images/icon/NAME.png>
```

Example:

```
./scaffold/add_item_to_list.sh --target=development --name=Arch --image=arch
```

About the arguments:

1. --target: The element with itens in the _layouts. For example, development.html
2. --name: The name of the new section
3. --image: The name for the new section
