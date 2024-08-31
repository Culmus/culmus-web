function parseKey(url)
{
  var query = url.search.substring(0);
  // key is the first word after the '?' character
  key = query.replace(/.*\?/,"");
  key = key.match(/^\w*/); // secure - only specific chars match

  return key;
}

function parseValue(url)
{
  var query = url.search.substring(0);

  // value is the first filename (anything containing words, dot, slash)
  // after the '=' character
  value = query.replace(/.*=/,"");
  value = value.match(/^[\w\.\/]*/); // secure - only specific chars match

  return value;
}

function redir(url)
{
  var newUrl;

  if (parseKey(url) == "fonts")
    newUrl = "fancy/index.html?fonts=" + parseValue(url);
  else if (parseKey(url) == "page")
    newUrl = parseValue(url);

  if (newUrl)
    window.clm_main.location.href=newUrl;
}

