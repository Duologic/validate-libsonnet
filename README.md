# validate-libsonnet

Type checking is a common grievance in the jsonnet eco-system, this library is an
aid to validate function parameters and other values.

Here's a comprehensive example validating the function arguments against the
arguments documented by docsonnet:

```jsonnet
local validate = import 'github.com/crdsonnet/validate-libsonnet/main.libsonnet';
local d = import 'github.com/jsonnet-libs/docsonnet/doc-util/main.libsonnet';

{
  '#func'::
    d.func.new(
      'sample function',
      args=[
        d.arg('num', d.T.number),
        d.arg('str', d.T.string),
        d.arg('enum', d.T.string, enums=['valid', 'values']),
      ],
    ),
  func(num, str, enum)::
    assert validate.checkParamsFromDocstring(
      [num, str, enum],
      self['#func'],
    );
    {/* do something here */ },

  return: self.func(100, 20, 'invalid'),
}

```

A failure output would look like this:

```
TRACE: main.libsonnet:95 
Invalid parameters:
  Parameter enum is invalid:
    Value "invalid" MUST match schema:
      {
        "enum": [
          "valid",
          "values"
        ],
        "type": "string"
      }
  Parameter str is invalid:
    Value 20 MUST match schema:
      {
        "type": "string"
      }
RUNTIME ERROR: Assertion failed
	example/fromdocstring.jsonnet:(15:5)-(19:31)	
	example/fromdocstring.jsonnet:21:11-40	object <anonymous>
	Field "return"	
	During manifestation	


```

## Install

```
jb install github.com/crdsonnet/validate-libsonnet@master
```

## Usage

```jsonnet
local validate = import 'github.com/crdsonnet/validate-libsonnet/main.libsonnet'
```


## Index

* [`fn checkParameters(checks)`](#fn-checkparameters)
* [`fn checkParamsFromDocstring(params, docstring)`](#fn-checkparamsfromdocstring)
* [`fn crdCheck(object, crds)`](#fn-crdcheck)
* [`fn getChecksFromDocstring(params, docstring)`](#fn-getchecksfromdocstring)
* [`fn schemaCheck(param, schema)`](#fn-schemacheck)

## Fields

### fn checkParameters

```jsonnet
checkParameters(checks)
```

PARAMETERS:

* **checks** (`object`)

`checkParameters` validates parameters against their `checks`.

```jsonnet
local validate = import 'github.com/crdsonnet/validate-libsonnet/main.libsonnet';

local func(arg) =
  assert validate.checkParameters({
    arg: std.isString(arg),
  });
  {/* do something here */ };

func(false)

```

A failure output would look like this:

```
TRACE: main.libsonnet:95 
Invalid parameters:
  Parameter enum is invalid:
    Value "invalid" MUST match schema:
      {
        "enum": [
          "valid",
          "values"
        ],
        "type": "string"
      }
  Parameter str is invalid:
    Value 20 MUST match schema:
      {
        "type": "string"
      }
RUNTIME ERROR: Assertion failed
	example/fromdocstring.jsonnet:(15:5)-(19:31)	
	example/fromdocstring.jsonnet:21:11-40	object <anonymous>
	Field "return"	
	During manifestation	


```

### fn checkParamsFromDocstring

```jsonnet
checkParamsFromDocstring(params, docstring)
```

PARAMETERS:

* **params** (`array`)
* **docstring** (`object`)

`checkParamsFromDocstring` validates `params` against a docsonnet `docstring` object.

```jsonnet
local validate = import 'github.com/crdsonnet/validate-libsonnet/main.libsonnet';
local d = import 'github.com/jsonnet-libs/docsonnet/doc-util/main.libsonnet';

{
  '#func'::
    d.func.new(
      'sample function',
      args=[
        d.arg('num', d.T.number),
        d.arg('str', d.T.string),
        d.arg('enum', d.T.string, enums=['valid', 'values']),
      ],
    ),
  func(num, str, enum)::
    assert validate.checkParamsFromDocstring(
      [num, str, enum],
      self['#func'],
    );
    {/* do something here */ },

  return: self.func(100, 20, 'invalid'),
}

```

A failure output would look like this:

```
TRACE: main.libsonnet:95 
Invalid parameters:
  Parameter enum is invalid:
    Value "invalid" MUST match schema:
      {
        "enum": [
          "valid",
          "values"
        ],
        "type": "string"
      }
  Parameter str is invalid:
    Value 20 MUST match schema:
      {
        "type": "string"
      }
RUNTIME ERROR: Assertion failed
	example/fromdocstring.jsonnet:(15:5)-(19:31)	
	example/fromdocstring.jsonnet:21:11-40	object <anonymous>
	Field "return"	
	During manifestation	


```

### fn crdCheck

```jsonnet
crdCheck(object, crds)
```

PARAMETERS:

* **object** (`object`)
* **crds** (`array`)

`crdCheck` validates `object` against a set of CRDs.

```jsonnet
local validate = import 'github.com/crdsonnet/validate-libsonnet/main.libsonnet';

local crds = std.parseYaml(importstr './crds.yaml');
local object = {
  kind: 'ContactPoint',
  apiVersion: 'alerting.grafana.crossplane.io/v1alpha1',
  spec: {
    deletionPolicy: null,
    forProvider: {},
  },
};

assert validate.crdCheck(object, crds); true


```

A failure output would look like this:

```
TRACE: validate.libsonnet:24 ERR invalid enum, value should be one of [
    "Orphan",
    "Delete"
]: 
null
RUNTIME ERROR: Assertion failed
	example/crdCheck.jsonnet:13:1-45	
	During evaluation	


```

### fn getChecksFromDocstring

```jsonnet
getChecksFromDocstring(params, docstring)
```

PARAMETERS:

* **params** (`array`)
* **docstring** (`object`)

`getChecksFromDocstring` returns checks for `params` derived from a docsonnet `docstring` object.
### fn schemaCheck

```jsonnet
schemaCheck(param, schema)
```

PARAMETERS:

* **param** (`any`)
* **schema** (`object`)

`schemaCheck` validates `param` against a JSON `schema`. Note that this function does not resolve "$ref" and recursion.