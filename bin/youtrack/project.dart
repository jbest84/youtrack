class YouTrackProject {
  String name;
  String shortName;

  YouTrackProject(this.name, this.shortName);

  YouTrackProject.fromJson(Map json) {
    name = json['name'];
    shortName = json['shortName'];
  }

  String toString() {
    return "Project{name: {$name}, shortName: ${shortName}}";
  }
}
