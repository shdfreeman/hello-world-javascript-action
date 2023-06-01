# Hello world javascript action

This action prints "Hello World" or "Hello" + the name of a person to greet to the log.

## Source
https://docs.github.com/en/actions/creating-actions/creating-a-javascript-action

[![GitHub Super-Linter](https://github.com/shdfreeman/
hello-world-javascript-action/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/marketplace/actions/super-linter)

## Inputs

### `who-to-greet`

**Required** The name of the person to greet. Default `"World"`.

## Outputs

### `time`

The time we greeted you.

## Example usage

```yaml
uses: actions/hello-world-javascript-action@e76147da8e5c81eaf017dede5645551d4b94427b
with:
  who-to-greet: 'Mona the Octocat'
```
