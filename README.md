# colony-validate-bp-action

Validate that blueprints and their dependencies are always valid in your repository. 
You can choose to validate all blueprints in your current repository or provide a list of files for validation.

# Usage

```yaml
- uses: QualiSystemsLab/colony-validate-bp-action@v0.0.1
  with:
    # The name of the Colony Space your repository is connected to
    space: MyTestSpace
    
    # Provide the long term Colony token which could be generated
    # on the 'Integrations' page under the Colony's Settings page
    # or generate a new one with the REST API
    colony_token: ${{ secrets.COLONY_TOKEN }}
    
    # [Optional] Specify a list of files you want to validate in csv format (comma-separated).
    # An action will validate all blueprints related to this list of files
    # If not set, all the blueprints in the branch will be validated
    fileslist: blueprints/Wordpress.yaml,applications/mysql/init.sh
```

# Examples

## Validate all blueprints

To validate all the blueprints, we first need to checkout the files and then run the validation

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

To save time, you can validate only those blueprints that are somehow related to changes in the latest commit. 
Here is how you can do it with a [cool](https://github.com/jitterbit/get-changed-files) GitHub action that returns a csv list of the added/changed files in a certain push or or pull request:

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
      with:
        format: 'csv'

    - name: Colony validate blueprints
      uses: QualiSystemsLab/colony-validate-bp-action@v0.0.1
      with:
        space: MyTestSpace
        # Check added and modified files
        fileslist: ${{ steps.files.outputs.added_modified  }}
        colony_token: ${{ secrets.COLONY_TOKEN }}
```
