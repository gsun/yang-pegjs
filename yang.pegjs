/*
 * YANG - A Data Modeling Language for the Network Configuration Protocol (NETCONF)
 *
 * http://tools.ietf.org/html/rfc6020
 *
 * Limitations & cleanup
 * - included errata
 * - doesn't check for repetition count of statements where "these stmts can appear in any order"
 *
 * @append ietf/rfc6020-yang-generic.pegjs
 * @append ietf/rfc3986-uri.pegjs
 * @append ietf/rfc5234-core-abnf.pegjs
 */

{
  function extractOptional(optional, index) {
    return optional != null ? optional[index] : null;
  }

  function extractList(list, index) {
    return list.map(function (element) { return element[index];});
  }

  function buildList(head, tail, index) {
    return [head].concat(extractList(tail, index));
  }
}

module_stmt
  = optsep k:module_keyword sep n:identifier_arg_str optsep "{" stmtsep h:module_header_stmts l:linkage_stmts m:meta_stmts r:revision_stmts b:body_stmts "}" optsep {
    return {
	  type:k,
	  name:n,
	  header:h,
	  linkage:l,
	  meta:m,
	  revision:r,
	  body:b
	};
  }

submodule_stmt
  = optsep k:submodule_keyword sep n:identifier_arg_str optsep "{" stmtsep h:submodule_header_stmts l:linkage_stmts m:meta_stmts r:revision_stmts b:body_stmts "}" optsep {
    return {
	  type:k,
	  name:n,
	  header:h,
	  linkage:l,
	  meta:m,
	  revision:r,
	  body:b
	};
  }
// these stmts can appear in any order
// CHANGE don't check repetition count
module_header_stmts
  = l:(module_header_stmt_ stmtsep)* {
    return extractList(l, 0);
  }

module_header_stmt_
  = yang_version_stmt
  / namespace_stmt
  / prefix_stmt

// these stmts can appear in any order
// CHANGE don't check repetition count
submodule_header_stmts
  = l:(submodule_header_stmt_ stmtsep)* {
    return extractList(l, 0);
  }

submodule_header_stmt_
  = yang_version_stmt
  / belongs_to_stmt

// these stmts can appear in any order
// CHANGE don't check repetition count
meta_stmts
  = l:(meta_stmt_ stmtsep)* {
    return extractList(l, 0);
  }

meta_stmt_
  = organization_stmt
  / contact_stmt
  / description_stmt
  / reference_stmt

// these stmts can appear in any order
// CHANGE don't check repetition count
linkage_stmts
  = l:(linkage_stmt_ stmtsep)* {
    return extractList(l, 0);
  }

linkage_stmt_
  = import_stmt
  / include_stmt

revision_stmts
  = l:(revision_stmt stmtsep)* {
    return extractList(l, 0);
  }

body_stmts
  = l:(body_stmt_ stmtsep)* {
    return extractList(l, 0);
  }

body_stmt_
  = extension_stmt
  / feature_stmt
  / identity_stmt
  / typedef_stmt
  / grouping_stmt
  / data_def_stmt
  / augment_stmt
  / rpc_stmt
  / notification_stmt
  / deviation_stmt

data_def_stmt
  = container_stmt
  / leaf_stmt
  / leaf_list_stmt
  / list_stmt
  / choice_stmt
  / anyxml_stmt
  / uses_stmt

yang_version_stmt
  = k:yang_version_keyword sep v:yang_version_arg_str optsep stmtend {
    return {
	  type:k,
	  version:v
	};
  }

yang_version_arg_str
  = DQUOTE v:yang_version_arg DQUOTE { return v; }
  / SQUOTE v:yang_version_arg SQUOTE { return v; }
  / yang_version_arg

yang_version_arg
  = "1"

import_stmt
  = k:import_keyword sep n:identifier_arg_str optsep "{" stmtsep p:prefix_stmt stmtsep d:(revision_date_stmt stmtsep)?
"}" {
  return {
    type:k,
	name:n,
	prefix:p,
	revision_date:extractOptional(d, 0)
  };
}

include_stmt
  = k:include_keyword sep n:identifier_arg_str optsep ";" { 
      return {
	  type:k,
	  name:n,
	  revision_date:null
	};
  } 
  / k:include_keyword sep n:identifier_arg_str optsep "{" stmtsep d:(revision_date_stmt stmtsep)? "}" {
    return {
	  type:k,
	  name:n,
	  revision_date:extractOptional(d, 0)
	};
  }

namespace_stmt
  = k:namespace_keyword sep u:uri_str optsep stmtend {
    return {
	  type:k,
	  uri:u
	};
  }

uri_str
  = DQUOTE u:uri DQUOTE { return u; }
  / SQUOTE u:uri SQUOTE { return u; }
  / uri

prefix_stmt
  = k:prefix_keyword sep p:prefix_arg_str optsep stmtend {
    return {
	  type:k,
	  prefix:p
	};
  }

belongs_to_stmt
  = k:belongs_to_keyword sep n:identifier_arg_str optsep "{" stmtsep p:prefix_stmt stmtsep "}" {
    return {
	  type:k,
	  name:n,
	  prefix:p
	};
  }

organization_stmt
  = k:organization_keyword sep v:string optsep stmtend {
    return {
	  type:k,
	  text:v
	};
  }

contact_stmt
  = k:contact_keyword sep v:string optsep stmtend {
    return {
	  type:k,
	  text:v
	};
  }

description_stmt
  = k:description_keyword sep v:string optsep stmtend {
    return {
	  type:k,
	  text:v
	};
  }

reference_stmt
  = k:reference_keyword sep v:string optsep stmtend {
    return {
	  type:k,
	  text:v
	};
  }

units_stmt
  = k:units_keyword sep v:string optsep stmtend {
    return {
	  type:k,
	  text:v
	};
  }

revision_stmt
  = k:revision_keyword sep d:revision_date optsep s:revision_stmt_subs {
    return {
	  type:k,
	  date:d,
	  subs:s
	};
  }

revision_stmt_subs 
  = ";" { return []; }
  / "{" stmtsep s:revision_stmt_subs_ "}" { return s; }
  
  
// CHANGE order doesn't matter
// CHANGE don't check repetition count
revision_stmt_subs_
  = l:(revision_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

revision_stmt_sub_
  = description_stmt
  / reference_stmt

revision_date
  = date_arg_str

revision_date_stmt
  = k:revision_date_keyword sep d:revision_date stmtend {
    return {
	  type:k,
	  date:d
	};
  }

extension_stmt
  = k:extension_keyword sep n:identifier_arg_str optsep s:extension_stmt_subs {
    return {
	  type:k,
	  name:n,
	  subs:s
	};
  }

extension_stmt_subs 
  = ";" { return []; }
  / "{" stmtsep s:extension_stmt_subs_ "}" { return s; }
  
// these stmts can appear in any order
// CHANGE don't check repetition count
extension_stmt_subs_
  = l:(extension_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

extension_stmt_sub_
  = argument_stmt
  / status_stmt
  / description_stmt
  / reference_stmt

argument_stmt
  = k:argument_keyword sep n:identifier_arg_str optsep ";" {
    return {
	  type:k,
	  name:n,
	  yin:null
	};
  } 
  / k:argument_keyword sep n:identifier_arg_str optsep "{" stmtsep y:(yin_element_stmt stmtsep)? "}" {
    return {
	  type:k,
	  name:n,
	  yin:extractOptional(y, 0)
	};
  }

yin_element_stmt
  = k:yin_element_keyword sep v:yin_element_arg_str stmtend {
    return {
	  type:k,
	  element:v
	};
  }

yin_element_arg_str
  = DQUOTE y:yin_element_arg DQUOTE { return y; }
  / SQUOTE y:yin_element_arg SQUOTE { return y; }
  / yin_element_arg

yin_element_arg
  = true_keyword
  / false_keyword

identity_stmt
  = k:identity_keyword sep n:identifier_arg_str optsep s:identity_stmt_subs {
    return {
	  type:k,
	  name:n,
	  subs:s
	};
  }

identity_stmt_subs 
  = ";" { return []; }
  / "{" stmtsep s:identity_stmt_subs_ "}" { return s; }
  
// these stmts can appear in any order
// CHANGE don't check repetition count
identity_stmt_subs_
  = l:(identity_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

identity_stmt_sub_
  = base_stmt
  / status_stmt
  / description_stmt
  / reference_stmt

base_stmt
  = k:base_keyword sep v:identifier_ref_arg_str optsep stmtend {
    return {
	  type:k,
	  name:v
	};
  }

feature_stmt
  = k:feature_keyword sep n:identifier_arg_str optsep s:feature_stmt_subs {
    return {
	  type:k,
	  name:n,
	  subs:s
	};
  }

feature_stmt_subs 
  = ";" { return []; }
  / "{" stmtsep s:feature_stmt_subs_ "}" { return s; }
  
// these stmts can appear in any order
// CHANGE don't check repetition count
feature_stmt_subs_
  = l:(feature_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

feature_stmt_sub_
  = if_feature_stmt
  / status_stmt
  / description_stmt
  / reference_stmt

if_feature_stmt
  = k:if_feature_keyword sep n:identifier_ref_arg_str optsep stmtend {
    return {
	  type:k,
	  name:n
	};
  }

typedef_stmt
  = k:typedef_keyword sep n:identifier_arg_str optsep "{" stmtsep s:typedef_stmt_subs_ "}" {
    return {
	  type:k,
	  name:n,
	  subs:s
	};
  }

// these stmts can appear in any order
// CHANGE don't check repetition count
typedef_stmt_subs_
  = l:(typedef_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

typedef_stmt_sub_
  = type_stmt
  / units_stmt
  / default_stmt
  / status_stmt
  / description_stmt
  / reference_stmt

type_stmt
  = k:type_keyword sep n:identifier_ref_arg_str optsep b:type_body_stmts {
    return {
	  type:k,
	  name:n,
	  body:b
	};
  }

type_body_stmts 
  = ";" { return null; }
  / "{" stmtsep s:type_body_stmts_ "}" { return s; }
  
// CHANGE add empty body alternative
// CHANGE to counteract making all *_restrictions/*_specification rule required
type_body_stmts_
  = numerical_restrictions
  / decimal64_specification
  / string_restrictions
  / enum_specification
  / leafref_specification
  / identityref_specification
  / instance_identifier_specification
  / bits_specification
  / union_specification
  / binary_specification
  / stmtsep

// CHANGE required
binary_specification
  = l:length_stmt stmtsep { return l; }

numerical_restrictions
  = r:range_stmt stmtsep { return r; }

range_stmt
  = k:range_keyword sep v:range_arg_str optsep s:range_stmt_subs {
    return {
	  type:k,
	  range:v,
	  subs:s
	};
  }

range_stmt_subs 
  = ";" { return []; }
  / "{" stmtsep s:range_stmt_subs_ "}" { return s; }
  
// these stmts can appear in any order
// CHANGE don't check repetition count
range_stmt_subs_
  = l:(range_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

range_stmt_sub_
  = error_message_stmt
  / error_app_tag_stmt
  / description_stmt
  / reference_stmt

// these stmts can appear in any order
decimal64_specification
  = f:fraction_digits_stmt stmtsep { return f; }

fraction_digits_stmt
  = k:fraction_digits_keyword sep v:fraction_digits_arg_str stmtend {
      return {
	      type:k,
		  value:v
	  };
  }

fraction_digits_arg_str
  = DQUOTE v:fraction_digits_arg DQUOTE { return v; }
  / SQUOTE v:fraction_digits_arg SQUOTE { return v; }
  / fraction_digits_arg

// CHANGE simplify ranges
fraction_digits_arg
  = $("1" [0-8]?)
  / [2-9]

// these stmts can appear in any order
// CHANGE required
// CHANGE don't check repetition count
string_restrictions
  = l:(string_restriction_ stmtsep)+ {
    return extractList(l, 0);
  }

string_restriction_
  = length_stmt
  / pattern_stmt

length_stmt
  = k:length_keyword sep n:length_arg_str optsep s:length_stmt_subs {
    return {
	  type:k,
	  name:n,
	  subs:s
	};
  }

length_stmt_subs 
  = ";" { return []; }
  / "{" stmtsep s:length_stmt_subs_ "}" { return s; }
  
// these stmts can appear in any order
// CHANGE don't check repetition count
length_stmt_subs_
  = l:(length_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

length_stmt_sub_
  = error_message_stmt
  / error_app_tag_stmt
  / description_stmt
  / reference_stmt

pattern_stmt
  = k:pattern_keyword sep n:string optsep s:pattern_stmt_subs {
    return {
	  type:k,
	  pattern:n,
	  subs:s
	};
  }

pattern_stmt_subs 
  = ";" { return []; }
  / "{" stmtsep s:pattern_stmt_subs_ "}" { return s; }
  
// these stmts can appear in any order
// CHANGE don't check repetition count
pattern_stmt_subs_
  = l:(pattern_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

pattern_stmt_sub_
  = error_message_stmt
  / error_app_tag_stmt
  / description_stmt
  / reference_stmt

default_stmt
  = k:default_keyword sep v:string stmtend {
    return {
	  type:k,
	  text:v
	};
  }

enum_specification
  = l:(enum_stmt stmtsep)+ {
    return extractList(l, 0);
  }

enum_stmt
  = k:enum_keyword sep v:string optsep s:enum_stmt_subs {
    return {
	  type:k,
	  text:v,
	  subs:s
	};
  }

enum_stmt_subs 
  = ";" { return []; }
  / "{" stmtsep s:enum_stmt_subs_ "}" { return s; }
  
// these stmts can appear in any order
// CHANGE don't check repetition count
enum_stmt_subs_
  = l:(enum_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

enum_stmt_sub_
  = value_stmt
  / status_stmt
  / description_stmt
  / reference_stmt

leafref_specification
  = p:path_stmt stmtsep { return p; }

path_stmt
  = k:path_keyword sep v:path_arg_str stmtend {
    return {
	  type:k,
	  path:v
	};
  }

require_instance_stmt
  = k:require_instance_keyword sep v:require_instance_arg_str stmtend {
    return {
	  type:k,
	  require:v
	};
  }

require_instance_arg_str
  = DQUOTE v:require_instance_arg DQUOTE { return v; }
  / SQUOTE v:require_instance_arg SQUOTE { return v; }
  / require_instance_arg

require_instance_arg
  = true_keyword
  / false_keyword

// CHANGE required
instance_identifier_specification
  = r:require_instance_stmt stmtsep { return r; }

identityref_specification
  = b:base_stmt stmtsep { return b; }

union_specification
  = l:(type_stmt stmtsep)+ {
    return extractList(l, 0);
  }

bits_specification
  = l:(bit_stmt stmtsep)+ {
    return extractList(l, 0);
  }

bit_stmt
  = k:bit_keyword sep n:identifier_arg_str optsep s:bit_stmt_subs {
    return {
	  type:k,
	  name:n,
	  subs:s
	};
  }

bit_stmt_subs 
  = ";" { return []; }
  / "{" stmtsep s:bit_stmt_subs_ "}" { return s; }
  
// these stmts can appear in any order
// CHANGE don't check repetition count
bit_stmt_subs_
  = l:(bit_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

bit_stmt_sub_
  = position_stmt
  / status_stmt
  / description_stmt
  / reference_stmt

position_stmt
  = k:position_keyword sep v:position_value_arg_str stmtend {
    return {
	  type:k,
	  position:v
	};
  }

position_value_arg_str
  = DQUOTE v:position_value_arg DQUOTE { return v; }
  / SQUOTE v:position_value_arg SQUOTE { return v; }
  / position_value_arg

position_value_arg
  = non_negative_integer_value

status_stmt
  = k:status_keyword sep v:status_arg_str stmtend {
    return {
	  type:k,
	  status:v
	};
  }

status_arg_str
  = DQUOTE v:status_arg DQUOTE { return v; }
  / SQUOTE v:status_arg SQUOTE { return v; }
  / status_arg

status_arg
  = current_keyword
  / obsolete_keyword
  / deprecated_keyword

config_stmt
  = k:config_keyword sep v:config_arg_str stmtend {
    return {
	  type:k,
	  config:v
	};
  }

config_arg_str
  = DQUOTE v:config_arg DQUOTE { return v; }
  / SQUOTE v:config_arg SQUOTE { return v; }
  / config_arg

config_arg
  = true_keyword
  / false_keyword

mandatory_stmt
  = k:mandatory_keyword sep v:mandatory_arg_str stmtend {
    return {
	  type:k,
	  mandatory:v
	};
  }

mandatory_arg_str
  = DQUOTE v:mandatory_arg DQUOTE { return v; }
  / SQUOTE v:mandatory_arg SQUOTE { return v; }
  / mandatory_arg

mandatory_arg
  = true_keyword
  / false_keyword

presence_stmt
  = k:presence_keyword sep v:string stmtend {
    return {
	  type:k,
	  text:v
	};
  }

ordered_by_stmt
  = ordered_by_keyword sep ordered_by_arg_str stmtend

ordered_by_arg_str
  = DQUOTE v:ordered_by_arg DQUOTE { return v; }
  / SQUOTE v:ordered_by_arg SQUOTE { return v; }
  / ordered_by_arg

ordered_by_arg
  = user_keyword
  / system_keyword

must_stmt
  = k:must_keyword sep v:string optsep s:must_stmt_subs {
    return {
	  type:k,
	  text:v,
	  subs:s
	};
  }

must_stmt_subs 
  = ";" { return []; }
  / "{" stmtsep s:must_stmt_subs_ "}" { return s; }
  
// these stmts can appear in any order
// CHANGE don't check repetition count
must_stmt_subs_
  = l:(must_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

must_stmt_sub_
  = error_message_stmt
  / error_app_tag_stmt
  / description_stmt
  / reference_stmt

error_message_stmt
  = k:error_message_keyword sep v:string stmtend {
    return {
	  type:k,
	  text:v
	};
  }

error_app_tag_stmt
  = k:error_app_tag_keyword sep v:string stmtend {
    return {
	  type:k,
	  text:v
	};
  }

min_elements_stmt
  = k:min_elements_keyword sep v:min_value_arg_str stmtend {
    return {
	  type:k,
	  value:v
	};
  }

min_value_arg_str
  = DQUOTE v:min_value_arg DQUOTE { return v; }
  / SQUOTE v:min_value_arg SQUOTE { return v; }
  / min_value_arg

min_value_arg
  = non_negative_integer_value

max_elements_stmt
  = k:max_elements_keyword sep v:max_value_arg_str stmtend {
    return {
	  type:k,
	  value:v
	};
  }

max_value_arg_str
  = DQUOTE v:max_value_arg DQUOTE { return v; }
  / SQUOTE v:max_value_arg SQUOTE { return v; }
  / max_value_arg

max_value_arg
  = unbounded_keyword
  / positive_integer_value

value_stmt
  = k:value_keyword sep v:integer_value_arg_str stmtend {
    return {
	  type:k,
	  integer:v
	};
  }

integer_value_arg_str
  = DQUOTE v:integer_value_arg DQUOTE { return v; }
  / SQUOTE v:integer_value_arg SQUOTE { return v; }
  / integer_value_arg

integer_value_arg
  = integer_value

grouping_stmt
  = k:grouping_keyword sep n:identifier_arg_str optsep s:grouping_stmt_subs {
    return {
	  type:k,
	  name:n,
	  subs:s
	};
  }

grouping_stmt_subs 
  = ";" { return []; }
  / "{" stmtsep s:grouping_stmt_subs_ "}" { return s; }
  
// these stmts can appear in any order
// CHANGE don't check repetition count
grouping_stmt_subs_
  = l:(grouping_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

grouping_stmt_sub_
  = status_stmt
  / description_stmt
  / reference_stmt
  / typedef_stmt
  / grouping_stmt
  / data_def_stmt

container_stmt
  = k:container_keyword sep n:identifier_arg_str optsep s:container_stmt_subs {
    return {
	  type:k,
	  name:n,
	  subs:s
	};
  }

container_stmt_subs 
  = ";" { return []; }
  / "{" stmtsep s:container_stmt_subs_ "}" { return s; }
  
// these stmts can appear in any order
// CHANGE don't check repetition count
container_stmt_subs_
  = l:(container_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

container_stmt_sub_
  = when_stmt
  / if_feature_stmt
  / must_stmt
  / presence_stmt
  / config_stmt
  / status_stmt
  / description_stmt
  / reference_stmt
  / typedef_stmt
  / grouping_stmt
  / data_def_stmt

leaf_stmt
  = k:leaf_keyword sep n:identifier_arg_str optsep "{" stmtsep s:leaf_stmt_subs_ "}" {
    return {
	  type:k,
	  name:n,
	  subs:s
	};
  }

// these stmts can appear in any order
// CHANGE don't check repetition count
leaf_stmt_subs_
  = l:(leaf_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

leaf_stmt_sub_
  = when_stmt
  / if_feature_stmt
  / type_stmt
  / units_stmt
  / must_stmt
  / default_stmt
  / config_stmt
  / mandatory_stmt
  / status_stmt
  / description_stmt
  / reference_stmt

leaf_list_stmt
  = k:leaf_list_keyword sep n:identifier_arg_str optsep "{" stmtsep s:leaf_list_stmt_subs_ "}" {
    return {
	  type:k,
	  name:n,
	  subs:s
	};
  }

// these stmts can appear in any order
// CHANGE don't check repetition count
leaf_list_stmt_subs_
  = l:(leaf_list_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

leaf_list_stmt_sub_
  = when_stmt
  / if_feature_stmt
  / type_stmt
  / units_stmt
  / must_stmt
  / config_stmt
  / min_elements_stmt
  / max_elements_stmt
  / ordered_by_stmt
  / status_stmt
  / description_stmt
  / reference_stmt

list_stmt
  = k:list_keyword sep n:identifier_arg_str optsep "{" stmtsep s:list_stmt_subs_ "}" {
    return {
	  type:k,
	  name:n,
	  subs:s
	};
  }
  
// these stmts can appear in any order
// CHANGE don't check repetition count
list_stmt_subs_
  = l:(list_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

list_stmt_sub_
  = when_stmt
  / if_feature_stmt
  / must_stmt
  / key_stmt
  / unique_stmt
  / config_stmt
  / min_elements_stmt
  / max_elements_stmt
  / ordered_by_stmt
  / status_stmt
  / description_stmt
  / reference_stmt
  / typedef_stmt
  / grouping_stmt
  / data_def_stmt

key_stmt
  = k:key_keyword sep v:key_arg_str stmtend {
    return {
	  type:k,
	  key:v
	};
  }

key_arg_str
  = DQUOTE v:key_arg DQUOTE { return v; }
  / SQUOTE v:key_arg SQUOTE { return v; }
  / key_arg

key_arg
  = h:node_identifier t:(sep node_identifier)* {
    return buildList(h, t, 1);
  }

unique_stmt
  = k:unique_keyword sep v:unique_arg_str stmtend {
    return {
	  type:k,
	  unique:v
	};
  }

unique_arg_str
  = DQUOTE v:unique_arg DQUOTE { return v; }
  / SQUOTE v:unique_arg SQUOTE { return v; }
  / unique_arg

unique_arg
  = h:descendant_schema_nodeid t:(sep descendant_schema_nodeid)* {
    return buildList(h, t, 1);
  }

choice_stmt
  = k:choice_keyword sep n:identifier_arg_str optsep s:choice_stmt_subs {
    return {
	  type:k,
	  name:n,
	  subs:s
	};
  }

choice_stmt_subs 
  = ";" { return []; }
  / "{" stmtsep s:choice_stmt_subs_ "}" { return s; }
  
// these stmts can appear in any order
// CHANGE don't check repetition count
choice_stmt_subs_
  = l:(choice_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

choice_stmt_sub_
  = when_stmt
  / if_feature_stmt
  / default_stmt
  / config_stmt
  / mandatory_stmt
  / status_stmt
  / description_stmt
  / reference_stmt
  / short_case_stmt
  / case_stmt

short_case_stmt
  = container_stmt
  / leaf_stmt
  / leaf_list_stmt
  / list_stmt
  / anyxml_stmt

case_stmt
  = k:case_keyword sep n:identifier_arg_str optsep s:case_stmt_subs {
    return {
	  type:k,
	  name:n,
	  subs:s
	};
  }

case_stmt_subs 
  = ";" { return []; }
  / "{" stmtsep s:case_stmt_subs_ "}" { return s; }
  
// these stmts can appear in any order
// CHANGE don't check repetition count
case_stmt_subs_
  = l:(case_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

case_stmt_sub_
  = when_stmt
  / if_feature_stmt
  / status_stmt
  / description_stmt
  / reference_stmt
  / data_def_stmt

anyxml_stmt
  = k:anyxml_keyword sep n:identifier_arg_str optsep s:anyxml_stmt_subs {
    return {
	  type:k,
	  name:n,
	  subs:s
	};
  }

anyxml_stmt_subs 
  = ";" { return []; }
  / "{" stmtsep s:anyxml_stmt_subs_ "}" { return s; }
    
// these stmts can appear in any order
// CHANGE don't check repetition count
anyxml_stmt_subs_
  = l:(anyxml_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

anyxml_stmt_sub_
  = when_stmt
  / if_feature_stmt
  / must_stmt
  / config_stmt
  / mandatory_stmt
  / status_stmt
  / description_stmt
  / reference_stmt

uses_stmt
  = k:uses_keyword sep n:identifier_ref_arg_str optsep s:uses_stmt_subs {
    return {
	  type:k,
	  name:n,
	  subs:s
	};
  }

uses_stmt_subs 
  = ";" { return []; }
  / "{" stmtsep s:uses_stmt_subs_ "}" { return s; }
  
// these stmts can appear in any order
// CHANGE don't check repetition count
uses_stmt_subs_
  = l:(uses_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

uses_stmt_sub_
  = when_stmt
  / if_feature_stmt
  / status_stmt
  / description_stmt
  / reference_stmt
  / refine_stmt
  / uses_augment_stmt

refine_stmt
  = k:refine_keyword sep n:refine_arg_str optsep s:refine_stmt_subs {
    return {
	  type:k,
	  name:n,
	  subs:s
	};
  }

refine_stmt_subs 
  = ";" { return []; }
  / "{" stmtsep s:refine_stmt_subs_ "}" { return s; }
  
refine_stmt_subs_
  = refine_container_stmts
  / refine_leaf_stmts
  / refine_leaf_list_stmts
  / refine_list_stmts
  / refine_choice_stmts
  / refine_case_stmts
  / refine_anyxml_stmts

refine_arg_str
  = DQUOTE v:refine_arg DQUOTE { return v; }
  / SQUOTE v:refine_arg SQUOTE { return v; }
  / refine_arg

refine_arg
  = descendant_schema_nodeid

// these stmts can appear in any order
// CHANGE don't check repetition count
refine_container_stmts
  = l:(refine_container_stmt_ stmtsep)* {
    return extractList(l, 0);
  }

refine_container_stmt_
  = must_stmt
  / presence_stmt
  / config_stmt
  / description_stmt
  / reference_stmt

// these stmts can appear in any order
// CHANGE don't check repetition count
refine_leaf_stmts
  = l:(refine_leaf_stmt_ stmtsep)* {
    return extractList(l, 0);
  }

refine_leaf_stmt_
  = must_stmt
  / default_stmt
  / config_stmt
  / mandatory_stmt
  / description_stmt
  / reference_stmt

// these stmts can appear in any order
// CHANGE don't check repetition count
refine_leaf_list_stmts
  = l:(refine_leaf_list_stmt_ stmtsep)* {
    return extractList(l, 0);
  }

refine_leaf_list_stmt_
  = must_stmt
  / config_stmt
  / min_elements_stmt
  / max_elements_stmt
  / description_stmt
  / reference_stmt

// these stmts can appear in any order
// CHANGE don't check repetition count
refine_list_stmts
  = l:(refine_list_stmt_ stmtsep)* {
    return extractList(l, 0);
  }

refine_list_stmt_
  = must_stmt
  / config_stmt
  / min_elements_stmt
  / max_elements_stmt
  / description_stmt
  / reference_stmt

// these stmts can appear in any order
// CHANGE don't check repetition count
refine_choice_stmts
  = l:(refine_choice_stmt_ stmtsep)* {
    return extractList(l, 0);
  }

refine_choice_stmt_
  = default_stmt
  / config_stmt
  / mandatory_stmt
  / description_stmt
  / reference_stmt

// these stmts can appear in any order
// CHANGE don't check repetition count
refine_case_stmts
  = l:(refine_case_stmt_ stmtsep)* {
    return extractList(l, 0);
  }

refine_case_stmt_
  = description_stmt
  / reference_stmt

// these stmts can appear in any order
// CHANGE don't check repetition count
refine_anyxml_stmts
  = l:(refine_anyxml_stmt_ stmtsep)* {
    return extractList(l, 0);
  }

refine_anyxml_stmt_
  = must_stmt
  / config_stmt
  / mandatory_stmt
  / description_stmt
  / reference_stmt

uses_augment_stmt
  = k:augment_keyword sep n:uses_augment_arg_str optsep "{" stmtsep s:uses_augment_stmt_subs_ "}" {
    return {
	  type:k,
	  name:n,
	  subs:s
	};
  }

// these stmts can appear in any order
// CHANGE don't check repetition count
uses_augment_stmt_subs_
  = l:(uses_augment_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

uses_augment_stmt_sub_
  = when_stmt
  / if_feature_stmt
  / status_stmt
  / description_stmt
  / reference_stmt
  / data_def_stmt
  / case_stmt

uses_augment_arg_str
  = DQUOTE v:uses_augment_arg DQUOTE { return v; }
  / SQUOTE v:uses_augment_arg SQUOTE { return v; }
  / uses_augment_arg

uses_augment_arg
  = descendant_schema_nodeid

augment_stmt
  = k:augment_keyword sep n:augment_arg_str optsep "{" stmtsep s:augment_stmt_subs_ "}" {
    return {
	  type:k,
	  name:n,
	  subs:s
	};
  }

// these stmts can appear in any order
// CHANGE don't check repetition count
augment_stmt_subs_
  = l:(augment_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

augment_stmt_sub_
  = when_stmt
  / if_feature_stmt
  / status_stmt
  / description_stmt
  / reference_stmt
  / data_def_stmt
  / case_stmt

augment_arg_str
  = DQUOTE v:augment_arg DQUOTE { return v; }
  / SQUOTE v:augment_arg SQUOTE { return v; }
  / augment_arg

augment_arg
  = absolute_schema_nodeid

when_stmt
  = k:when_keyword sep v:string optsep s:when_stmt_subs {
    return {
	  type:k,
	  text:v,
	  subs:s
	};
  }

when_stmt_subs 
  = ";" { return []; }
  / "{" stmtsep s:when_stmt_subs_ "}" { return s; }
  
// these stmts can appear in any order
// CHANGE don't check repetition count
when_stmt_subs_
  = l:(when_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

when_stmt_sub_
  = description_stmt
  / reference_stmt

rpc_stmt
  = k:rpc_keyword sep n:identifier_arg_str optsep s:rpc_stmt_subs {
    return {
	  type:k,
	  name:n,
	  subs:s
	};
  }

rpc_stmt_subs 
  = ";" { return []; }
  / "{" stmtsep s:rpc_stmt_subs_ "}" { return s; }
    
// these stmts can appear in any order
// CHANGE don't check repetition count
rpc_stmt_subs_
  = l:(rpc_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

rpc_stmt_sub_
  = if_feature_stmt
  / status_stmt
  / description_stmt
  / reference_stmt
  / typedef_stmt
  / grouping_stmt
  / input_stmt
  / output_stmt

input_stmt
  = k:input_keyword optsep "{" stmtsep s:input_stmt_subs_ "}" {
    return {
	  type:k,
	  subs:s
	};
  }

// these stmts can appear in any order
// CHANGE don't check repetition count
input_stmt_subs_
  = l:(input_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

input_stmt_sub_
  = typedef_stmt
  / grouping_stmt
  / data_def_stmt

output_stmt
  = k:output_keyword optsep "{" stmtsep s:output_stmt_subs_ "}" {
    return {
	  type:k,
	  subs:s
	};
  }

// these stmts can appear in any order
// CHANGE don't check repetition count
output_stmt_subs_
  = l:(output_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

output_stmt_sub_
  = typedef_stmt
  / grouping_stmt
  / data_def_stmt

notification_stmt
  = k:notification_keyword sep n:identifier_arg_str optsep s:notification_stmt_subs {
    return {
	  type:k,
	  name:n,
	  subs:s
	};
  }

notification_stmt_subs
  = ";" { return []; }
  / "{" stmtsep s:notification_stmt_subs "}" { return s; }
  
// these stmts can appear in any order
// CHANGE don't check repetition count
notification_stmt_subs_
  = l:(notification_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

notification_stmt_sub_
  = if_feature_stmt
  / status_stmt
  / description_stmt
  / reference_stmt
  / typedef_stmt
  / grouping_stmt
  / data_def_stmt

deviation_stmt
  = k:deviation_keyword sep v:deviation_arg_str optsep "{" stmtsep s:deviation_stmt_subs_ "}" {
    return {
	  type:k,
	  deviation:v,
	  subs:s
	};
  }

 
// these stmts can appear in any order
// CHANGE don't check repetition count
deviation_stmt_subs_
  = l:(deviation_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

deviation_stmt_sub_
  = description_stmt
  / reference_stmt
  / deviate_not_supported_stmt
  / deviate_add_stmt
  / deviate_replace_stmt
  / deviate_delete_stmt

deviation_arg_str
  = DQUOTE v:deviation_arg DQUOTE { return v; }
  / SQUOTE v:deviation_arg SQUOTE { return v; }
  / deviation_arg

deviation_arg
  = absolute_schema_nodeid

deviate_not_supported_stmt
  = k:deviate_keyword sep v:not_supported_keyword optsep (";" / "{" stmtsep "}") {
    return {
	  type:k,
	  sub_type:v
	};
  }

deviate_add_stmt
  = k:deviate_keyword sep sk:add_keyword optsep s:deviate_add_stmt_subs {
    return {
	  type:k,
	  sub_type:sk,
	  subs:s
	};
  }

deviate_add_stmt_subs 
  = ";" { return []; }
  / "{" stmtsep s:deviate_add_stmt_subs_ "}" { return s; }
  
// these stmts can appear in any order
// CHANGE don't check repetition count
deviate_add_stmt_subs_
  = l:(deviate_add_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

deviate_add_stmt_sub_
  = units_stmt
  / must_stmt
  / unique_stmt
  / default_stmt
  / config_stmt
  / mandatory_stmt
  / min_elements_stmt
  / max_elements_stmt

deviate_delete_stmt
  = k:deviate_keyword sep sk:delete_keyword optsep s:deviate_delete_stmt_subs {
    return {
	  type:k,
	  sub_type:sk,
	  subs:s
	};
  }

deviate_delete_stmt_subs 
  = ";" { return []; }
  / "{" stmtsep s:deviate_delete_stmt_subs_ "}" { return s; }
  
// these stmts can appear in any order
// CHANGE don't check repetition count
deviate_delete_stmt_subs_
  = l:(deviate_delete_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

deviate_delete_stmt_sub_
  = units_stmt
  / must_stmt
  / unique_stmt
  / default_stmt

deviate_replace_stmt
  = k:deviate_keyword sep sk:replace_keyword optsep s:deviate_replace_stmt_subs {
    return {
	  type:k,
	  sub_type:sk,
	  subs:s
	};
  }

deviate_replace_stmt_subs 
  = ";" { return []; }
  / "{" stmtsep s:deviate_replace_stmt_subs_ "}" { return s; }
  
// these stmts can appear in any order
// CHANGE don't check repetition count
deviate_replace_stmt_subs_
  = l:(deviate_replace_stmt_sub_ stmtsep)* {
    return extractList(l, 0);
  }

deviate_replace_stmt_sub_
  = type_stmt
  / units_stmt
  / default_stmt
  / config_stmt
  / mandatory_stmt
  / min_elements_stmt
  / max_elements_stmt

// Ranges

range_arg_str
  = DQUOTE v:range_arg DQUOTE { return v; }
  / SQUOTE v:range_arg SQUOTE { return v; }
  / range_arg
  
range_arg
  = h:range_part t:(optsep "|" optsep range_part)* {
    return buildList(h, t, 3);
  }

range_part
  = h:range_boundary t:(optsep ".." optsep range_boundary)? {
    return [h].concat(extractOptional(t, 3));
  }

range_boundary
  = min_keyword
  / max_keyword
  / integer_value
  / decimal_value

// Lengths

length_arg_str
  = DQUOTE v:length_arg DQUOTE { return v; }
  / SQUOTE v:length_arg SQUOTE { return v; }
  / length_arg

length_arg
  = h:length_part t:(optsep "|" optsep length_part)* {
    return buildList(h, t, 3);
  }

length_part
  = h:length_boundary t:(optsep ".." optsep length_boundary)? {
    return [h].concat(extractOptional(t, 3));
  }

length_boundary
  = min_keyword
  / max_keyword
  / non_negative_integer_value

// Date

date_arg_str
  = DQUOTE v:date_arg DQUOTE { return v; }
  / SQUOTE v:date_arg SQUOTE { return v; }
  / date_arg

date_arg
  = $(DIGIT DIGIT DIGIT DIGIT "-" DIGIT DIGIT "-" DIGIT DIGIT)

// Schema Node Identifiers

schema_nodeid
  = a:absolute_schema_nodeid {
    return {
	    type:"absolute_node",
		list:a
	};
  }
  / d:descendant_schema_nodeid {
    return {
	    type:"descendant_node",
		list:d
	};
  }

absolute_schema_nodeid
  = n:("/" node_identifier)+ {
    return extractList(n, 1);
  }

descendant_schema_nodeid
  = n:node_identifier a:(absolute_schema_nodeid)? {
    return [n].concat(extractOptional(a, 0));
  }

node_identifier
  = p:(prefix ":")? i:identifier {
    return { 
	    prefix:extractOptional(p, 0),
	    name:i
	};
  }

// Instance Identifiers

instance_identifier
  = ("/" (node_identifier predicate*))+

predicate
  = "[" WSP* (predicate_expr / pos) WSP* "]"

// CHANGE simplify/reuse reference for quoted string
predicate_expr
  = (node_identifier / ".") WSP* "=" WSP* string_quoted_

pos
  = non_negative_integer_value

// leafref path

path_arg_str
  = DQUOTE v:path_arg DQUOTE { return v; }
  / SQUOTE v:path_arg SQUOTE { return v; }
  / path_arg

path_arg
  = $absolute_path
  / $relative_path

absolute_path
  = ("/" (node_identifier path_predicate*))+

relative_path
  = (".." "/")+ descendant_path

descendant_path
  = node_identifier (path_predicate* absolute_path)?

path_predicate
  = "[" WSP* path_equality_expr WSP* "]"

path_equality_expr
  = node_identifier WSP* "=" WSP* path_key_expr

path_key_expr
  = current_function_invocation WSP* "/" WSP* rel_path_keyexpr

rel_path_keyexpr
  = (".." WSP* "/" WSP*)+ (node_identifier WSP* "/" WSP*)* node_identifier

// Keywords, using abnfgen's syntax for case_sensitive strings

// statement keywords
anyxml_keyword
  = "anyxml"
argument_keyword
  = "argument"
augment_keyword
  = "augment"
base_keyword
  = "base"
belongs_to_keyword
  = "belongs-to"
bit_keyword
  = "bit"
case_keyword
  = "case"
choice_keyword
  = "choice"
config_keyword
  = "config"
contact_keyword
  = "contact"
container_keyword
  = "container"
default_keyword
  = "default"
description_keyword
  = "description"
enum_keyword
  = "enum"
error_app_tag_keyword
  = "error-app-tag"
error_message_keyword
  = "error-message"
extension_keyword
  = "extension"
deviation_keyword
  = "deviation"
deviate_keyword
  = "deviate"
feature_keyword
  = "feature"
fraction_digits_keyword
  = "fraction-digits"
grouping_keyword
  = "grouping"
identity_keyword
  = "identity"
if_feature_keyword
  = "if-feature"
import_keyword
  = "import"
include_keyword
  = "include"
input_keyword
  = "input"
key_keyword
  = "key"
leaf_keyword
  = "leaf"
leaf_list_keyword
  = "leaf-list"
length_keyword
  = "length"
list_keyword
  = "list"
mandatory_keyword
  = "mandatory"
max_elements_keyword
  = "max-elements"
min_elements_keyword
  = "min-elements"
module_keyword
  = "module"
must_keyword
  = "must"
namespace_keyword
  = "namespace"
notification_keyword
  = "notification"
ordered_by_keyword
  = "ordered-by"
organization_keyword
  = "organization"
output_keyword
  = "output"
path_keyword
  = "path"
pattern_keyword
  = "pattern"
position_keyword
  = "position"
prefix_keyword
  = "prefix"
presence_keyword
  = "presence"
range_keyword
  = "range"
reference_keyword
  = "reference"
refine_keyword
  = "refine"
require_instance_keyword
  = "require-instance"
revision_keyword
  = "revision"
revision_date_keyword
  = "revision-date"
rpc_keyword
  = "rpc"
status_keyword
  = "status"
submodule_keyword
  = "submodule"
type_keyword
  = "type"
typedef_keyword
  = "typedef"
unique_keyword
  = "unique"
units_keyword
  = "units"
uses_keyword
  = "uses"
value_keyword
  = "value"
when_keyword
  = "when"
yang_version_keyword
  = "yang-version"
yin_element_keyword
  = "yin-element"

// other keywords

add_keyword
  = "add"
current_keyword
  = "current"
delete_keyword
  = "delete"
deprecated_keyword
  = "deprecated"
false_keyword
  = "false"
max_keyword
  = "max"
min_keyword
  = "min"
not_supported_keyword
  = "not_supported"
obsolete_keyword
  = "obsolete"
replace_keyword
  = "replace"
system_keyword
  = "system"
true_keyword
  = "true"
unbounded_keyword
  = "unbounded"
user_keyword
  = "user"

current_function_invocation
  = current_keyword WSP* "(" WSP* ")"

// Basic Rules

prefix_arg_str
  = DQUOTE v:prefix_arg DQUOTE { return v; }
  / SQUOTE v:prefix_arg SQUOTE { return v; }
  / prefix_arg

prefix_arg
  = prefix

identifier_arg_str
  = DQUOTE v:identifier_arg DQUOTE { return v; }
  / SQUOTE v:identifier_arg SQUOTE { return v; }
  / identifier_arg

identifier_arg
  = identifier

identifier_ref_arg_str
  = DQUOTE v:identifier_ref_arg DQUOTE { return v; }
  / SQUOTE v:identifier_ref_arg SQUOTE { return v; }
  / identifier_ref_arg

identifier_ref_arg
  = p:(prefix ":")? i:identifier {
    return { 
	    prefix:extractOptional(p, 0),
	    name:i
	};
  }

integer_value
  = "-" non_negative_integer_value
  / non_negative_integer_value

non_negative_integer_value
  = "0"
  / positive_integer_value

positive_integer_value
  = $(non_zero_digit DIGIT*)

zero_integer_value
  = $(DIGIT+)

stmtend
  = ";"
  / "{" unknown_statement* "}"

non_zero_digit
  = [1-9]

decimal_value
  = integer_value ("." zero_integer_value)

/* rfc6020-yang-generic.pegjs */
/*
 * YANG - A Data Modeling Language for the Network Configuration Protocol (NETCONF)
 *
 * http://tools.ietf.org/html/rfc6020
 *
 * Limitations & cleanup
 * - this is a generic grammar parsing only "unknown" i.e. generic statements
 *
 * @append ietf/rfc5234-core-abnf.pegjs
 */

// CHANGE allow stmtsep before and after
// CHANGE allow optsep after
// CHANGE group "prefix:" for action simplification
unknown_statement
  = p:prefix ":" i:identifier s:(sep string)? optsep ";" optsep {
    return {
	    type:"unknown",
	    prefix:p,
		id:i,
		param:extractOptional(s, 1),
		subs:null
	};
  }
  / p:prefix ":" i:identifier s:(sep string)? optsep "{" stmtsep_no_stmt_ sub:(unknown_statement2 stmtsep_no_stmt_)* "}" optsep {
    return {
	    type:"unknown",
	    prefix:p,
		id:i,
		param:extractOptional(s, 1),
		subs:extractList(sub, 0)
	};
  }

// CHANGE allow stmtsep before and after
// CHANGE allow optsep after
unknown_statement2
  = p:(prefix ":")? i:identifier s:(sep string)? optsep ";" optsep {
    return {
	    prefix:extractOptional(p, 0),
		id:i,
		param:extractOptional(s, 1)
	};
  }
  / p:(prefix ":")? i:identifier s:(sep string)? optsep "{" stmtsep_no_stmt_ sub:(unknown_statement2 stmtsep_no_stmt_)* "}" optsep {
    return {
	    prefix:extractOptional(p, 0),
		id:i,
		param:extractOptional(s, 1),
		subs:extractList(sub, 0)
	};
  }

prefix
  = identifier

// An identifier MUST NOT start with (('X'|'x') ('M'|'m') ('L'|'l'))
// CHANGED encode rule for identifier not to start with <xml>
identifier
  = $(!identifier_xml_ (ALPHA / "_") (ALPHA / DIGIT / "_" / "-" / ".")*)

identifier_xml_
  = [Xx][Mm][Ll]

// CHANGE restrict quoted: no inner quote (even escaped)
// CHANGE restrict unquoted: no inner quote, no semicolon, open curly bracket
// CHANGE allow multiline strings, concatenated by +
string
  = string_quoted_
  / string_unquoted_

string_quoted_
  = DQUOTE head:$(!DQUOTE .)* DQUOTE tail:(optsep "+" optsep DQUOTE $(!DQUOTE .)* DQUOTE)* {
    return buildList(head, tail, 4).join('');
  }
  / SQUOTE head:$(!SQUOTE .)* SQUOTE tail:(optsep "+" optsep SQUOTE $(!SQUOTE .)* SQUOTE)* {
    return buildList(head, tail, 4).join('');
  }

string_unquoted_
  = $(!(sep [";{]) [^";{])+

// unconditional separator
sep
  = $(WSP / line_break)+

// CHANGE accept comments as well
optsep
  = $(WSP / line_break / comment_)*

// CHANGE DRY optsep
// CHANGE allow comments
stmtsep
  = optsep (comment_ / unknown_statement)*

stmtsep_no_stmt_
  = optsep comment_*

comment_
  = single_line_comment_ optsep
  / multi_line_comment_ optsep

single_line_comment_
  = "//" $(!line_break .)* line_break

multi_line_comment_
  = "/*" $(!"*/" .)+ "*/"

line_break
  = CRLF
  / LF

// ' (Single Quote)
SQUOTE
  = "'"

/* ietf/rfc3986-uri.pegjs */
/*
 * Uniform Resource Identifier (URI): Generic Syntax
 *
 * http://tools.ietf.org/html/rfc3986
 *
 * <host> element has been renamed to <hostname> as a dirty workaround for
 * element being re-defined with another meaning in HTTPbis
 *
 * @append ietf/rfc5234-core-abnf.pegjs
 */

/* http://tools.ietf.org/html/rfc3986#section-2.1 Percent-Encoding */
pct_encoded
  = $("%" HEXDIG HEXDIG)


/* http://tools.ietf.org/html/rfc3986#section-2.2 Reserved Characters */
reserved
  = gen_delims
  / sub_delims

gen_delims
  = ":"
  / "/"
  / "?"
  / "#"
  / "["
  / "]"
  / "@"

sub_delims
  = "!"
  / "$"
  / "&"
  / "'"
  / "("
  / ")"
  / "*"
  / "+"
  / ","
  / ";"
  / "="


/* http://tools.ietf.org/html/rfc3986#section-2.3 Unreserved Characters */
unreserved
  = ALPHA
  / DIGIT
  / "-"
  / "."
  / "_"
  / "~"


/* http://tools.ietf.org/html/rfc3986#section-3 Syntax Components */
uri
  = scheme ":" hier_part ("?" query)? ("#" fragment)? { return text(); }

hier_part
  = "//" authority path_abempty
  / path_absolute
  / path_rootless
  / path_empty


/* http://tools.ietf.org/html/rfc3986#section-3.1 Scheme */
scheme
  = $(ALPHA (ALPHA / DIGIT / "+" / "-" / ".")*)


/* http://tools.ietf.org/html/rfc3986#section-3.2 Authority */
// CHANGE host to hostname
authority
  = (userinfo "@")? hostname (":" port)?


/* http://tools.ietf.org/html/rfc3986#section-3.2.1 User Information */
userinfo
  = $(unreserved / pct_encoded / sub_delims / ":")*


/* http://tools.ietf.org/html/rfc3986#section-3.2.2 Host */
// CHANGE host to hostname
// CHANGE Add forward check for reg_name
hostname
  = IP_literal !reg_name_item_
  / IPv4address !reg_name_item_
  / reg_name

IP_literal
  = "[" (IPv6address / IPvFuture) "]"

IPvFuture
  = "v" $(HEXDIG+) "." $( unreserved
                        /*
                        // CHANGE Ignore due to https://github.com/for-GET/core-pegjs/issues/8
                        / sub_delims
                        */
                        / ":"
                        )+

IPv6address
  = $(                                                            h16_ h16_ h16_ h16_ h16_ h16_ ls32
     /                                                       "::"      h16_ h16_ h16_ h16_ h16_ ls32
     / (                                               h16)? "::"           h16_ h16_ h16_ h16_ ls32
     / (                               h16_?           h16)? "::"                h16_ h16_ h16_ ls32
     / (                         (h16_ h16_?)?         h16)? "::"                     h16_ h16_ ls32
     / (                   (h16_ (h16_ h16_?)?)?       h16)? "::"                          h16_ ls32
     / (             (h16_ (h16_ (h16_ h16_?)?)?)?     h16)? "::"                               ls32
     / (       (h16_ (h16_ (h16_ (h16_ h16_?)?)?)?)?   h16)? "::"                               h16
     / ( (h16_ (h16_ (h16_ (h16_ (h16_ h16_?)?)?)?)?)? h16)? "::"
     )

ls32
  // least_significant 32 bits of address
  = h16 ":" h16
  / IPv4address

h16_
  = h16 ":"

h16
  // 16 bits of address represented in hexadecimal
  = $(HEXDIG (HEXDIG (HEXDIG HEXDIG?)?)?)

IPv4address
  = $(dec_octet "." dec_octet "." dec_octet "." dec_octet)

// CHANGE order in reverse for greedy matching
dec_octet
  = $( "25" [\x30-\x35]      // 250-255
     / "2" [\x30-\x34] DIGIT // 200-249
     / "1" DIGIT DIGIT       // 100-199
     / [\x31-\x39] DIGIT     // 10-99
     / DIGIT                 // 0-9
     )

reg_name
  = $(reg_name_item_*)
reg_name_item_
  = unreserved
  / pct_encoded
  /*
  // CHANGE Ignore due to https://github.com/for-GET/core-pegjs/issues/8
  / sub_delims
  */


/* http://tools.ietf.org/html/rfc3986#section-3.2.3 Port */
port
  = $(DIGIT*)


/* http://tools.ietf.org/html/rfc3986#section-3.3 Path */
path
  = path_abempty  // begins with "/" or is empty
  / path_absolute // begins with "/" but not "//"
  / path_noscheme // begins with a non_colon segment
  / path_rootless // begins with a segment
  / path_empty    // zero characters

path_abempty
  = $("/" segment)*

path_absolute
  = $("/" (segment_nz ("/" segment)*)?)

path_noscheme
  = $(segment_nz_nc ("/" segment)*)

path_rootless
  = $(segment_nz ("/" segment)*)

path_empty
  = ""

segment
  = $(pchar*)

segment_nz
  = $(pchar+)

segment_nz_nc
  // non_zero_length segment without any colon ":"
  = $(unreserved / pct_encoded / sub_delims / "@")+

pchar
  = unreserved
  / pct_encoded
  / sub_delims
  / ":"
  / "@"


/* http://tools.ietf.org/html/rfc3986#section-3.4 Query */
query
  = $(pchar / "/" / "?")*


/* http://tools.ietf.org/html/rfc3986#section-3.5 Fragment */
fragment
  = $(pchar / "/" / "?")*


/* http://tools.ietf.org/html/rfc3986#section-4.1 URI Reference */
uri_reference
  = uri
  / relative_ref


/* http://tools.ietf.org/html/rfc3986#section-4.2 Relative Reference */
relative_ref
  = relative_part ("?" query)? ("#" fragment)?

relative_part
  = "//" authority path_abempty
  / path_absolute
  / path_noscheme
  / path_empty


/* http://tools.ietf.org/html/rfc3986#section-4.3 Absolute URI */
absolute_uri
  = scheme ":" hier_part ("?" query)?

/* ietf/rfc5234-core-abnf.pegjs */
/*
 * Augmented BNF for Syntax Specifications: ABNF
 *
 * http://tools.ietf.org/html/rfc5234
 */

/* http://tools.ietf.org/html/rfc5234#appendix-B Core ABNF of ABNF */  
ALPHA
  = [\x41-\x5A]
  / [\x61-\x7A]

BIT
  = "0"
  / "1"

CHAR
  = [\x01-\x7F]

CR
  = "\x0D"

CRLF
  = CR LF

CTL
  = [\x00-\x1F]
  / "\x7F"

DIGIT
  = [\x30-\x39]

DQUOTE
  = [\x22]

HEXDIG
  = DIGIT
  / "A"i
  / "B"i
  / "C"i
  / "D"i
  / "E"i
  / "F"i

HTAB
  = "\x09"

LF
  = "\x0A"

LWSP
  = $(WSP / CRLF WSP)*

OCTET
  = [\x00-\xFF]

SP
  = "\x20"

VCHAR
  = [\x21-\x7E]

WSP
  = SP
  / HTAB