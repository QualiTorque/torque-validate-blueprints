# torque-validate-bp-action

This action validates your blueprints and their dependencies are always valid in your repository as part of your CI/CD pipeline or just whenever files are changed. 
You can choose to validate all the blueprints in your current repository or provide a list of files for validation.

# Usage

```yaml
- uses: QualiTorque/torque-validate-bp-action@v0.0.3
  with:
    # The name of the Torque Space your repository is connected to
    space: MyTestSpace
    
    # Provide the long term Torque token. You can generate it in Torque > Settings > Integrations
    # or via the REST API.
    torque_token: ${{ secrets.TORQUE_TOKEN }}
    
    # [Optional] Specify a list of blueprint YAML files you want to validate in csv format (comma-separated).
    # An action will validate all blueprints related to this list of files.
    # If not set, all the blueprints in the branch will be validated.
    fileslist: blueprints/Wordpress.yaml,applications/mysql/mysql.yaml
```

# Examples

## Validate all blueprints

To validate all the blueprints, we first need to check out the files and then run the validation

```yaml
name: Validation
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1

    - uses: QualiTorque/torque-validate-bp-action@v0.0.3
      with:
        space: MyTestSpace
        torque_token: ${{ secrets.TORQUE_TOKEN }}
```

## Validate only blueprints affected by latest change

To save time, you can validate only those blueprints that are somehow related to changes in the latest commit. 
Here is how you can do it with a [cool](https://github.com/jitterbit/get-changed-files) GitHub action that returns a csv list of the added/changed files in a certain push or pull request:

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

    - name: Torque validate blueprints
      uses: QualiTorque/torque-validate-bp-action@v0.0.3
      with:
        space: MyTestSpace
        # Check added and modified files
        fileslist: ${{ steps.files.outputs.added_modified  }}
        torque_token: ${{ secrets.TORQUE_TOKEN }}
```
