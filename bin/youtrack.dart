/*
 * Exports issues from youtrack.
 */
import "dart:io";
import "dart:convert";
import "dart:async";
import "project.dart";

// TODO: Make this a config option
const String BASE_URL = "https://saleslogix.myjetbrains.com/youtrack/rest";

const EXIT_CODE_OK = 0;
const EXIT_CODE_ERROR = 1;

void main() {
  HttpClient client = new HttpClient();

  login(client).then((HttpClientResponse res) {
    print("Login results: ${res.reasonPhrase}");

    if (res.statusCode == HttpStatus.OK) {
      getProjects(client, res).then((List<Project> projects) {
        Future.forEach(projects, (Project project) {
          return exportIssues(client, project.shortName, res).then((File f) {
            print("Wrote file ${f.path}.");
          });
        }).then((_) {
          print("Done writing files. Shutting down.");
          client.close();
          exit(EXIT_CODE_OK);
        });
      });
    } else {
      // Bad login
      exit(EXIT_CODE_ERROR);
    }
  });
}

Future<HttpClientResponse> login(HttpClient client) {
  stdout.write("Username: ");
  var user = stdin.readLineSync();

  stdout.write("Password: ");
  stdin.echoMode = false;
  var password = stdin.readLineSync();
  stdin.echoMode = true;
  stdout.writeln();

  var loginUrl = "${BASE_URL}/user/login?login=${user}&password=${password}";

  return client.postUrl(Uri.parse(loginUrl)).then((req) => req.close());
}

Future<File> exportIssues(HttpClient client, String project,
    HttpClientResponse prevResp) {

  var exportURL =
      "${BASE_URL}/export/${project}/issues?max=5000";// The max param in this URL should match what the administrator has configured in youtrack settings

  return client.getUrl(Uri.parse(exportURL)).then((HttpClientRequest req) {
    req.cookies.addAll(prevResp.cookies);
    return req.close();
  }).then((HttpClientResponse res) {
    return res.transform(UTF8.decoder).join('').then((String val) {
      File foo = new File("${project}.xml");
      return foo.writeAsString(val, mode: WRITE);
    });
  });
}

Future<List<Project>> getProjects(HttpClient client,
    HttpClientResponse prevResp) {
  var projectsUrl = "${BASE_URL}/project/all";
  return client.getUrl(Uri.parse(projectsUrl)).then((HttpClientRequest req) {
    req.cookies.addAll(prevResp.cookies);
    req.headers.add("Accept", "application/json");
    return req.close();
  }).then((HttpClientResponse res) {
    return res.transform(UTF8.decoder).join('').then((String val) {
      List<Map> json = JSON.decode(val);
      List<Project> results = new List<Project>();
      json.forEach((Map entry) {
        results.add(new Project.fromJson(entry));
      });

      return results;
    });
  });
}