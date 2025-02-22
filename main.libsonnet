local v = import './validate.libsonnet';
local d = import 'github.com/jsonnet-libs/docsonnet/doc-util/main.libsonnet';

{
  local root = self,

  '#':
    d.package.new(
      'validate-libsonnet',
      'github.com/crdsonnet/validate-libsonnet',
      |||
        Type checking is a common grievance in the jsonnet eco-system, this library is an
        aid to validate function parameters and other values.

        Here's a comprehensive example validating the function arguments against the
        arguments documented by docsonnet:

        ```jsonnet
        %s
        ```

        A failure output would look like this:

        ```
        %s
        ```
      ||| % [
        std.strReplace(
          importstr 'example/fromdocstring.jsonnet',
          '../main.libsonnet',
          'github.com/crdsonnet/validate-libsonnet/main.libsonnet',
        ),
        std.strReplace(
          importstr 'example/fromdocstring.jsonnet.output',
          '../main.libsonnet',
          'github.com/crdsonnet/validate-libsonnet/main.libsonnet',
        ),
      ],
      std.thisFile,
    )
    + d.package.withUsageTemplate(
      "local validate = import '%(import)s'"
    ),

  '#checkParameters': d.fn(
    |||
      `checkParameters` validates parameters against their `checks`.

      ```jsonnet
      %s
      ```

      A failure output would look like this:

      ```
      %s
      ```
    ||| % [
      std.strReplace(
        importstr 'example/simple.jsonnet',
        '../main.libsonnet',
        'github.com/crdsonnet/validate-libsonnet/main.libsonnet',
      ),
      std.strReplace(
        importstr 'example/fromdocstring.jsonnet.output',
        '../main.libsonnet',
        'github.com/crdsonnet/validate-libsonnet/main.libsonnet',
      ),
    ],
    args=[d.arg('checks', d.T.object)],
  ),
  checkParameters(checks):
    local failures = [
      'Parameter %s is invalid%s' % [
        n,
        (if (std.isArray(checks[n]))
         then ':' + std.join('\n  ', checks[n][1:])
         else '.'),
      ]
      for n in std.objectFields(checks)
      if (std.isArray(checks[n]) && !checks[n][0])
        || (std.isBoolean(checks[n]) && !checks[n])
    ];
    local tests = std.all([
      if std.isArray(checks[n])
      then checks[n][0]
      else checks[n]
      for n in std.objectFields(checks)
      if (std.isArray(checks[n]) && !checks[n][0])
        || (std.isBoolean(checks[n]) && !checks[n])
    ]);
    if tests
    then true
    else
      std.trace(
        std.join(
          '\n  ',
          ['\nInvalid parameters:']
          + failures
        ),
        false
      ),

  '#checkParamsFromDocstring': d.fn(
    |||
      `checkParamsFromDocstring` validates `params` against a docsonnet `docstring` object.

      ```jsonnet
      %s
      ```

      A failure output would look like this:

      ```
      %s
      ```
    ||| % [
      std.strReplace(
        importstr 'example/fromdocstring.jsonnet',
        '../main.libsonnet',
        'github.com/crdsonnet/validate-libsonnet/main.libsonnet',
      ),
      std.strReplace(
        importstr 'example/fromdocstring.jsonnet.output',
        '../main.libsonnet',
        'github.com/crdsonnet/validate-libsonnet/main.libsonnet',
      ),
    ],
    args=[
      d.arg('params', d.T.array),
      d.arg('docstring', d.T.object),
    ],
  ),
  checkParamsFromDocstring(params, docstring):
    root.checkParameters(
      root.getChecksFromDocstring(params, docstring)
    ),

  '#getChecksFromDocstring': d.fn(
    '`getChecksFromDocstring` returns checks for `params` derived from a docsonnet `docstring` object.',
    args=[
      d.arg('params', d.T.array),
      d.arg('docstring', d.T.object),
    ],
  ),
  getChecksFromDocstring(params, docstring):
    local args = docstring['function'].args;
    assert std.length(args) == std.length(params)
           : 'checkFromDocstring: expect equal number of args as params';

    local hasEnum(arg) = 'enums' in arg && std.isArray(arg.enums);
    {
      [args[i].name]:
        root.schemaCheck(
          params[i],
          {
            type: args[i].type,
            [if hasEnum(args[i]) then 'enum']: args[i].enums,
          }
        )
      for i in std.range(0, std.length(params) - 1)
    },

  '#schemaCheck': d.fn(
    '`schemaCheck` validates `param` against a JSON `schema`. Note that this function does not resolve "$ref" and recursion.',
    args=[
      d.arg('param', d.T.any),
      d.arg('schema', d.T.object),
    ],
  ),
  schemaCheck(param, schema):
    local indent = '    ';
    [
      v.validateQuietly(param, schema),
      '\n%sValue %s MUST match schema:' % [indent, std.manifestJson(param)],
      indent + std.manifestJsonEx(schema, '  ', '\n  ' + indent),
    ],

  '#crdCheck': d.fn(
    |||
      `crdCheck` validates `object` against a set of CRDs.

      ```jsonnet
      %s
      ```

      A failure output would look like this:

      ```
      %s
      ```
    ||| % [
      std.strReplace(
        importstr 'example/crdCheck.jsonnet',
        '../main.libsonnet',
        'github.com/crdsonnet/validate-libsonnet/main.libsonnet',
      ),
      std.strReplace(
        importstr 'example/crdCheck.jsonnet.output',
        '../main.libsonnet',
        'github.com/crdsonnet/validate-libsonnet/main.libsonnet',
      ),
    ],
    args=[
      d.arg('object', d.T.object),
      d.arg('crds', d.T.array),
    ],
  ),
  crdCheck(object, crds):
    local splitApiVersion = std.splitLimit(object.apiVersion, '/', 1);
    local group = splitApiVersion[0];
    local version = splitApiVersion[1];
    local kind = object.kind;

    local findVersion(versions, version) =
      std.filter(
        function(v)
          v.name == version,
        versions
      );


    local foundcrds =
      std.filter(
        function(crd)
          crd.spec.group == group
          && crd.spec.names.kind == kind,
        crds
      );

    assert std.length(foundcrds) > 0 : 'No CRD found for GroupVersionKind: %s' % std.join('/', [group, version, kind]);
    assert std.length(foundcrds) == 1 : 'More than one CRD found for GroupVersionKind: %s' % std.join('/', [group, version, kind]);

    local crd = foundcrds[0];

    local versionobjs =
      std.filter(
        function(v)
          v.name == version,
        crd.spec.versions
      );

    assert std.length(versionobjs) > 0 : 'No version found for GroupVersionKind: %s' % std.join('/', [group, version, kind]);
    assert std.length(versionobjs) == 1 : 'More than one version found for GroupVersionKind: %s' % std.join('/', [group, version, kind]);

    local versionobj = versionobjs[0];

    v.validate(object, versionobj.schema.openAPIV3Schema),
}
