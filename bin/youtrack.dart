/*
 * Exports issues from youtrack.
 */
import "dart:io";
import "dart:convert";
import "dart:async";
import "youtrack/project.dart";

// TODO: Make this a config option
const String BASE_URL = "https://saleslogix.myjetbrains.com/youtrack/rest";

const EXIT_CODE_OK = 0;
const EXIT_CODE_ERROR = 1;

main() async {
  HttpClient client = new HttpClient();

  HttpClientResponse res = await login(client);
  print("Login results: ${res.reasonPhrase}");

  if (res.statusCode == HttpStatus.OK) {
    List<YouTrackProject> projects = await getYouTrackProjects(client, res);
    Future.forEach(projects, (YouTrackProject project) async {
      File f = await exportIssues(client, project.shortName, res);
      print("Wrote file ${f.path}.");
    }).then((_) {
      print("Done writing files. Shutting down.");
      client.close();
      exit(EXIT_CODE_OK);
    });
  } else {
    // Bad login
    exit(EXIT_CODE_ERROR);
  }
}

Future<HttpClientResponse> login(HttpClient client) async {
  stdout.write("Username: ");
  var user = stdin.readLineSync();

  stdout.write("Password: ");
  stdin.echoMode = false;
  var password = stdin.readLineSync();
  stdin.echoMode = true;
  stdout.writeln();

  var loginUrl = "${BASE_URL}/user/login?login=${user}&password=${password}";

  HttpClientRequest req = await client.postUrl(Uri.parse(loginUrl));
  return req.close();
}

Future<File> exportIssues (HttpClient client, String project,
    HttpClientResponse prevResp) async {
  var exportURL =
      "${BASE_URL}/export/${project}/issues?max=5000";// The max param in this URL should match what the administrator has configured in youtrack settings

  HttpClientRequest req = await client.getUrl(Uri.parse(exportURL));
  req.cookies.addAll(prevResp.cookies);
  HttpClientResponse res = await req.close();

  String val = await res.transform(UTF8.decoder).join('');
  File file = new File("${project}.xml");
  return file.writeAsString(val, mode: WRITE);
}

Future<List<YouTrackProject>> getYouTrackProjects(HttpClient client, HttpClientResponse prev) async {
  var projectsUrl = "${BASE_URL}/project/all";

  HttpClientResponse res = await getResponse(client, projectsUrl, prev);
  String val = await res.transform(UTF8.decoder).join('');
  List<Map> json = JSON.decode(val);
  List<YouTrackProject> results = new List<YouTrackProject>();
  json.forEach((Map entry) {
    results.add(new YouTrackProject.fromJson(entry));
  });

  return results;
}

Future<HttpClientResponse> getResponse(HttpClient client, String url,
    HttpClientResponse prev) async {

  HttpClientRequest req = await client.getUrl(Uri.parse(url));
  req.cookies.addAll(prev.cookies);
  req.headers.add("Accept", "application/json");
  return req.close();
}
