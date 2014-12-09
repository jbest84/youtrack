class YouTrackIssue {
  String name;
  String shortName;

  String id;
  String jiraId;
  String projectShortName;
  String numberInProject;
  String summary;
  String description;
  String created;
  String updated;
  String updaterName;
  String resolved;
  String reporterName;
  String voterName;
  String commentsCount;
  String votes;
  String permittedGroup;
  String comment;
  String tag;
  String field;

  YouTrackIssue();

  YouTrackIssue.fromJson(Map json) {
    name = json['name'];
    shortName = json['shortName'];
  }

  String toString() {
    return "YouTrackIssue{name: {$name}, shortName: ${shortName}}";
  }
}
