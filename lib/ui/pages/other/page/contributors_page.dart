// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/config/app_colors.dart';
import 'package:flutter_app/src/config/app_link.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/ui/other/list_view_animator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:github/github.dart';
import 'package:url_launcher/url_launcher.dart';

class ContributorsPage extends StatelessWidget {
  final github = GitHub();
  final repositorySlug = RepositorySlug(AppLink.githubOwner, AppLink.githubName);

  ContributorsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(R.current.Contribution),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        R.current.projectLink,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          const url = AppLink.gitHub;
                          launchUrl(Uri.parse(url));
                        },
                        child: Container(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    R.current.github,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                              Row(
                                children: const [
                                  Expanded(
                                    child: Text(AppLink.gitHub),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        R.current.Contributors,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                FutureBuilder<List<Contributor>>(
                  future: github.repositories.listContributors(repositorySlug).toList(),
                  builder: (BuildContext context, AsyncSnapshot<List<Contributor>> snapshot) {
                    if (snapshot.hasData) {
                      List<Contributor> contributorList = snapshot.data;
                      return ListView.builder(
                        itemCount: contributorList.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          Contributor contributor = contributorList[index];
                          return InkWell(
                            onTap: () {
                              launchUrl(Uri.parse(contributor.htmlUrl));
                            },
                            child: WidgetAnimator(
                              Container(
                                padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: CachedNetworkImage(
                                        imageUrl: contributor.avatarUrl,
                                        imageBuilder: (context, imageProvider) => CircleAvatar(
                                          radius: 15.0,
                                          backgroundImage: imageProvider,
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 10),
                                    ),
                                    Text(contributor.login)
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Icon(Icons.error),
                      );
                    }
                    return const Center(
                      child: SpinKitDoubleBounce(
                        color: AppColors.mainColor,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
}
