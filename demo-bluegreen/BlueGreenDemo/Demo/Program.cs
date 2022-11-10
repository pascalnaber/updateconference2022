using System.Text;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", GetContent);



async Task GetContent(HttpContext context)
{
    string backgroundColor = Environment.GetEnvironmentVariable("backgroundcolor") ?? "powderblue";
    string text = Environment.GetEnvironmentVariable("text") ?? "Hello World!";
    context.Response.ContentType = "text/html";
    await context.Response.Body.WriteAsync(Encoding.UTF8.GetBytes(@$"
<!DOCTYPE html>
<html>
<body style='background-color:{backgroundColor};'>
<h1>{text}</h1>
</body>
</html>
"
));

}


app.Run();



//@"
//<!DOCTYPE html>
//<html>
//<body style='background-color:powderblue;'>
//<h1>This is a heading </h1>
//<p>This is a paragraph.</p>
//</body>
//</html>
//"