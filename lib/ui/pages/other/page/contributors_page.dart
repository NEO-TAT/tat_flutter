// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/config/app_colors.dart';
import 'package:flutter_app/src/config/app_link.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/ui/other/list_view_animator.dart';
import 'package:flutter_app/ui/other/route_utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:github/github.dart';

class ContributorsPage extends StatelessWidget {
  final github = GitHub();
  final repositorySlug = RepositorySlug(AppLink.githubOwnerName, AppLink.tatRepoName);

  ContributorsPage({super.key});

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
                          const url = AppLink.tatGitHubRepoUrlString;
                          RouteUtils.toWebViewPage(initialUrl: Uri.parse(url));
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
                                    child: Text(AppLink.tatGitHubRepoUrlString),
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
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final contributorList = snapshot.data;
                      return ListView.builder(
                        itemCount: contributorList?.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final contributor = contributorList![index];

                          return InkWell(
                            onTap: () {
                              RouteUtils.toWebViewPage(initialUrl: Uri.parse(contributor.htmlUrl ?? ''));
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
                                        imageUrl: contributor.avatarUrl ?? '',
                                        imageBuilder: (context, imageProvider) => CircleAvatar(
                                          radius: 15.0,
                                          backgroundImage: imageProvider,
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 10),
                                    ),
                                    Text(contributor.login ?? '')
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
