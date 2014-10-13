class Project {
  String name;
  String shortName;

  Project(this.name, this.shortName);

  Project.fromJson(Map json) {
    name = json['name'];
    shortName = json['shortName'];
  }

  String toString() {
    return "Project{name: {$name}, shortName: ${shortName}}";
  }
}
