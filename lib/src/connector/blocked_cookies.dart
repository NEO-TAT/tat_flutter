final List<RegExp> blockedCookieNamePatterns = [
  // The school backend added a cookie to the response header,
  // and its name style is BIGipServerVPFl/...........,
  // and in this name, there are characters that do not meet the requirements (/),
  // which will cause dio parsing errors, so it needs to be filtered out.
  // Please refer to this article
  // https://juejin.cn/post/6844903934042046472
  // for more details.
  RegExp('BIGipServer')
];
