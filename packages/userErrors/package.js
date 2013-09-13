Package.describe({ 
  summary: "A pattern to display applications errors to the user" 
});

Package.on_use(function(api, where) {
  api.use(['minimongo', 'mongo-livedata', 'templating'], 'client');
  api.add_files(['userErrors.js', 'userErrors_list.html', 'userErrors_list.js'], 'client');
});
