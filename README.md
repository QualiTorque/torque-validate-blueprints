# colony-validate-bp-action

Enable validation in your Colony Blueprints Repo. 
You can choose to validate all blueprints in your current repository or provide a list of files for validation.

# Usage

```yaml
- uses: QualiSystemsLab/colony-validate-bp-action@v0.0.1
  with:
    # The name of Colony Space your repo connected to
    space: MyTestSpace
    
    # Provide the long term Colony token which could be generated
    # on 'Integrations' page in Colony UI
    colony_token: ${{ secrets.COLONY_TOKEN }}
    
    # [Optional] Specify a list of files you want to validate in csv format (comma-separated).
    # An action will validate all blueprints related to this list of files
    # If not set, all blueprints in repo will be validated
    fileslist: blueprints/Wordpress.yaml,applications/mysql/init.sh
```

# Examples

## Validate all blueprints

If we want to validate all blueprints, we first need to checkout a repo and then run validation

```yaml
name: Validation
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1

    - uses: QualiSystemsLab/colony-validate-bp-action@v0.0.1
      with:
        space: MyTestSpace
        colony_token: ${{ secrets.COLONY_TOKEN }}
```

## Validate only blueprints affected by latest change

It would be really nice idea to validate only those blueprints that somehow related to changes in the latest commit. Here is how you can do it with a [cool](https://github.com/jitterbit/get-changed-files) GitHub action allowing you to fetch a list of changed files:

```yaml
name: Validation
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v1

    - name: Get changed files
      id: files
      uses: jitterbit/get-changed-files@v1

    - name: Colony validate blueprints
      uses: QualiSystemsLab/colony-validate-bp-action@v0.0.1
      with:
        space: MyTestSpace
        # Check added and modified files
        fileslist: ${{ steps.files.outputs.added_modified  }}
        colony_token: ${{ secrets.COLONY_TOKEN }}
```
