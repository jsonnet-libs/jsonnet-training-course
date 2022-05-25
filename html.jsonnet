local template = importstr 'template.html';

function(title, body)
  template % { title: title, body: body }
