import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class CustomChatTheme extends ChatTheme {
  /// Creates a default chat theme. Use this constructor if you want to
  /// override only a couple of properties, otherwise create a new class
  /// which extends [ChatTheme]
  const CustomChatTheme({
    Widget? attachmentButtonIcon,
    EdgeInsets? attachmentButtonMargin,
    Color backgroundColor = Colors.black,
    EdgeInsets dateDividerMargin = const EdgeInsets.only(
      bottom: 32,
      top: 16,
    ),
    TextStyle dateDividerTextStyle = const TextStyle(
      color: neutral2,
      fontSize: 12,
      fontWeight: FontWeight.w800,
      height: 1.333,
    ),
    Widget? deliveredIcon,
    Widget? documentIcon,
    TextStyle emptyChatPlaceholderTextStyle = const TextStyle(
      color: neutral2,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
    Color errorColor = error,
    Widget? errorIcon,
    Color inputBackgroundColor = neutral0,
    BorderRadius inputBorderRadius = const BorderRadius.vertical(
      top: Radius.circular(20),
    ),
    Decoration? inputContainerDecoration,
    EdgeInsets inputMargin = EdgeInsets.zero,
    EdgeInsets inputPadding = const EdgeInsets.fromLTRB(24, 20, 24, 20),
    Color inputTextColor = neutral7,
    Color? inputTextCursorColor,
    InputDecoration inputTextDecoration = const InputDecoration(
      border: InputBorder.none,
      contentPadding: EdgeInsets.zero,
      isCollapsed: true,
    ),
    TextStyle inputTextStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
    double messageBorderRadius = 20,
    double messageInsetsHorizontal = 20,
    double messageInsetsVertical = 16,
    Color primaryColor = primary,
    TextStyle receivedEmojiMessageTextStyle = const TextStyle(fontSize: 40),
    TextStyle? receivedMessageBodyBoldTextStyle,
    TextStyle? receivedMessageBodyCodeTextStyle,
    TextStyle? receivedMessageBodyLinkTextStyle,
    TextStyle receivedMessageBodyTextStyle = const TextStyle(
      color: neutral0,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
    TextStyle receivedMessageCaptionTextStyle = const TextStyle(
      color: neutral2,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.333,
    ),
    Color receivedMessageDocumentIconColor = primary,
    TextStyle receivedMessageLinkDescriptionTextStyle = const TextStyle(
      color: neutral0,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.428,
    ),
    TextStyle receivedMessageLinkTitleTextStyle = const TextStyle(
      color: neutral0,
      fontSize: 16,
      fontWeight: FontWeight.w800,
      height: 1.375,
    ),
    Color secondaryColor = secondary,
    Widget? seenIcon,
    Widget? sendButtonIcon,
    EdgeInsets? sendButtonMargin,
    Widget? sendingIcon,
    TextStyle sentEmojiMessageTextStyle = const TextStyle(fontSize: 40),
    TextStyle? sentMessageBodyBoldTextStyle,
    TextStyle? sentMessageBodyCodeTextStyle,
    TextStyle? sentMessageBodyLinkTextStyle,
    TextStyle sentMessageBodyTextStyle = const TextStyle(
      color: neutral7,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
    TextStyle sentMessageCaptionTextStyle = const TextStyle(
      color: neutral7WithOpacity,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.333,
    ),
    Color sentMessageDocumentIconColor = neutral7,
    TextStyle sentMessageLinkDescriptionTextStyle = const TextStyle(
      color: neutral7,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.428,
    ),
    TextStyle sentMessageLinkTitleTextStyle = const TextStyle(
      color: neutral7,
      fontSize: 16,
      fontWeight: FontWeight.w800,
      height: 1.375,
    ),
    EdgeInsets statusIconPadding = const EdgeInsets.symmetric(horizontal: 4),
    Color userAvatarImageBackgroundColor = Colors.transparent,
    List<Color> userAvatarNameColors = colors,
    TextStyle userAvatarTextStyle = const TextStyle(
      color: neutral7,
      fontSize: 12,
      fontWeight: FontWeight.w800,
      height: 1.333,
    ),
    TextStyle userNameTextStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w800,
      height: 1.333,
    ),
  }) : super(
          attachmentButtonIcon: attachmentButtonIcon,
          attachmentButtonMargin: attachmentButtonMargin,
          backgroundColor: backgroundColor,
          dateDividerMargin: dateDividerMargin,
          dateDividerTextStyle: dateDividerTextStyle,
          deliveredIcon: deliveredIcon,
          documentIcon: documentIcon,
          emptyChatPlaceholderTextStyle: emptyChatPlaceholderTextStyle,
          errorColor: errorColor,
          errorIcon: errorIcon,
          inputBackgroundColor: inputBackgroundColor,
          inputBorderRadius: inputBorderRadius,
          inputContainerDecoration: inputContainerDecoration,
          inputMargin: inputMargin,
          inputPadding: inputPadding,
          inputTextColor: inputTextColor,
          inputTextCursorColor: inputTextCursorColor,
          inputTextDecoration: inputTextDecoration,
          inputTextStyle: inputTextStyle,
          messageBorderRadius: messageBorderRadius,
          messageInsetsHorizontal: messageInsetsHorizontal,
          messageInsetsVertical: messageInsetsVertical,
          primaryColor: primaryColor,
          receivedEmojiMessageTextStyle: receivedEmojiMessageTextStyle,
          receivedMessageBodyBoldTextStyle: receivedMessageBodyBoldTextStyle,
          receivedMessageBodyCodeTextStyle: receivedMessageBodyCodeTextStyle,
          receivedMessageBodyLinkTextStyle: receivedMessageBodyLinkTextStyle,
          receivedMessageBodyTextStyle: receivedMessageBodyTextStyle,
          receivedMessageCaptionTextStyle: receivedMessageCaptionTextStyle,
          receivedMessageDocumentIconColor: receivedMessageDocumentIconColor,
          receivedMessageLinkDescriptionTextStyle:
              receivedMessageLinkDescriptionTextStyle,
          receivedMessageLinkTitleTextStyle: receivedMessageLinkTitleTextStyle,
          secondaryColor: secondaryColor,
          seenIcon: seenIcon,
          sendButtonIcon: sendButtonIcon,
          sendButtonMargin: sendButtonMargin,
          sendingIcon: sendingIcon,
          sentEmojiMessageTextStyle: sentEmojiMessageTextStyle,
          sentMessageBodyBoldTextStyle: sentMessageBodyBoldTextStyle,
          sentMessageBodyCodeTextStyle: sentMessageBodyCodeTextStyle,
          sentMessageBodyLinkTextStyle: sentMessageBodyLinkTextStyle,
          sentMessageBodyTextStyle: sentMessageBodyTextStyle,
          sentMessageCaptionTextStyle: sentMessageCaptionTextStyle,
          sentMessageDocumentIconColor: sentMessageDocumentIconColor,
          sentMessageLinkDescriptionTextStyle:
              sentMessageLinkDescriptionTextStyle,
          sentMessageLinkTitleTextStyle: sentMessageLinkTitleTextStyle,
          statusIconPadding: statusIconPadding,
          userAvatarImageBackgroundColor: userAvatarImageBackgroundColor,
          userAvatarNameColors: userAvatarNameColors,
          userAvatarTextStyle: userAvatarTextStyle,
          userNameTextStyle: userNameTextStyle,
        );
}

/// Dark chat theme which extends [ChatTheme]
@immutable
class DarkChatTheme extends ChatTheme {
  /// Creates a dark chat theme. Use this constructor if you want to
  /// override only a couple of properties, otherwise create a new class
  /// which extends [ChatTheme]
  const DarkChatTheme({
    Widget? attachmentButtonIcon,
    EdgeInsets? attachmentButtonMargin,
    Color backgroundColor = dark,
    EdgeInsets dateDividerMargin = const EdgeInsets.only(
      bottom: 32,
      top: 16,
    ),
    TextStyle dateDividerTextStyle = const TextStyle(
      color: neutral7,
      fontSize: 12,
      fontWeight: FontWeight.w800,
      height: 1.333,
    ),
    Widget? deliveredIcon,
    Widget? documentIcon,
    TextStyle emptyChatPlaceholderTextStyle = const TextStyle(
      color: neutral2,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
    Color errorColor = error,
    Widget? errorIcon,
    Color inputBackgroundColor = secondaryDark,
    BorderRadius inputBorderRadius = const BorderRadius.vertical(
      top: Radius.circular(20),
    ),
    Decoration? inputContainerDecoration,
    EdgeInsets inputMargin = EdgeInsets.zero,
    EdgeInsets inputPadding = const EdgeInsets.fromLTRB(24, 20, 24, 20),
    Color inputTextColor = neutral7,
    Color? inputTextCursorColor,
    InputDecoration inputTextDecoration = const InputDecoration(
      border: InputBorder.none,
      contentPadding: EdgeInsets.zero,
      isCollapsed: true,
    ),
    TextStyle inputTextStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
    double messageBorderRadius = 20,
    double messageInsetsHorizontal = 20,
    double messageInsetsVertical = 16,
    Color primaryColor = primary,
    TextStyle receivedEmojiMessageTextStyle = const TextStyle(fontSize: 40),
    TextStyle? receivedMessageBodyBoldTextStyle,
    TextStyle? receivedMessageBodyCodeTextStyle,
    TextStyle? receivedMessageBodyLinkTextStyle,
    TextStyle receivedMessageBodyTextStyle = const TextStyle(
      color: neutral7,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
    TextStyle receivedMessageCaptionTextStyle = const TextStyle(
      color: neutral7WithOpacity,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.333,
    ),
    Color receivedMessageDocumentIconColor = primary,
    TextStyle receivedMessageLinkDescriptionTextStyle = const TextStyle(
      color: neutral7,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.428,
    ),
    TextStyle receivedMessageLinkTitleTextStyle = const TextStyle(
      color: neutral7,
      fontSize: 16,
      fontWeight: FontWeight.w800,
      height: 1.375,
    ),
    Color secondaryColor = secondaryDark,
    Widget? seenIcon,
    Widget? sendButtonIcon,
    EdgeInsets? sendButtonMargin,
    Widget? sendingIcon,
    TextStyle sentEmojiMessageTextStyle = const TextStyle(fontSize: 40),
    TextStyle? sentMessageBodyBoldTextStyle,
    TextStyle? sentMessageBodyCodeTextStyle,
    TextStyle? sentMessageBodyLinkTextStyle,
    TextStyle sentMessageBodyTextStyle = const TextStyle(
      color: neutral7,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
    TextStyle sentMessageCaptionTextStyle = const TextStyle(
      color: neutral7WithOpacity,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.333,
    ),
    Color sentMessageDocumentIconColor = neutral7,
    TextStyle sentMessageLinkDescriptionTextStyle = const TextStyle(
      color: neutral7,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.428,
    ),
    TextStyle sentMessageLinkTitleTextStyle = const TextStyle(
      color: neutral7,
      fontSize: 16,
      fontWeight: FontWeight.w800,
      height: 1.375,
    ),
    EdgeInsets statusIconPadding = const EdgeInsets.symmetric(horizontal: 4),
    Color userAvatarImageBackgroundColor = Colors.transparent,
    List<Color> userAvatarNameColors = colors,
    TextStyle userAvatarTextStyle = const TextStyle(
      color: neutral7,
      fontSize: 12,
      fontWeight: FontWeight.w800,
      height: 1.333,
    ),
    TextStyle userNameTextStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w800,
      height: 1.333,
    ),
  }) : super(
          attachmentButtonIcon: attachmentButtonIcon,
          attachmentButtonMargin: attachmentButtonMargin,
          backgroundColor: backgroundColor,
          dateDividerMargin: dateDividerMargin,
          dateDividerTextStyle: dateDividerTextStyle,
          deliveredIcon: deliveredIcon,
          documentIcon: documentIcon,
          emptyChatPlaceholderTextStyle: emptyChatPlaceholderTextStyle,
          errorColor: errorColor,
          errorIcon: errorIcon,
          inputBackgroundColor: inputBackgroundColor,
          inputBorderRadius: inputBorderRadius,
          inputContainerDecoration: inputContainerDecoration,
          inputMargin: inputMargin,
          inputPadding: inputPadding,
          inputTextColor: inputTextColor,
          inputTextCursorColor: inputTextCursorColor,
          inputTextDecoration: inputTextDecoration,
          inputTextStyle: inputTextStyle,
          messageBorderRadius: messageBorderRadius,
          messageInsetsHorizontal: messageInsetsHorizontal,
          messageInsetsVertical: messageInsetsVertical,
          primaryColor: primaryColor,
          receivedEmojiMessageTextStyle: receivedEmojiMessageTextStyle,
          receivedMessageBodyBoldTextStyle: receivedMessageBodyBoldTextStyle,
          receivedMessageBodyCodeTextStyle: receivedMessageBodyCodeTextStyle,
          receivedMessageBodyLinkTextStyle: receivedMessageBodyLinkTextStyle,
          receivedMessageBodyTextStyle: receivedMessageBodyTextStyle,
          receivedMessageCaptionTextStyle: receivedMessageCaptionTextStyle,
          receivedMessageDocumentIconColor: receivedMessageDocumentIconColor,
          receivedMessageLinkDescriptionTextStyle:
              receivedMessageLinkDescriptionTextStyle,
          receivedMessageLinkTitleTextStyle: receivedMessageLinkTitleTextStyle,
          secondaryColor: secondaryColor,
          seenIcon: seenIcon,
          sendButtonIcon: sendButtonIcon,
          sendButtonMargin: sendButtonMargin,
          sendingIcon: sendingIcon,
          sentEmojiMessageTextStyle: sentEmojiMessageTextStyle,
          sentMessageBodyBoldTextStyle: sentMessageBodyBoldTextStyle,
          sentMessageBodyCodeTextStyle: sentMessageBodyCodeTextStyle,
          sentMessageBodyLinkTextStyle: sentMessageBodyLinkTextStyle,
          sentMessageBodyTextStyle: sentMessageBodyTextStyle,
          sentMessageCaptionTextStyle: sentMessageCaptionTextStyle,
          sentMessageDocumentIconColor: sentMessageDocumentIconColor,
          sentMessageLinkDescriptionTextStyle:
              sentMessageLinkDescriptionTextStyle,
          sentMessageLinkTitleTextStyle: sentMessageLinkTitleTextStyle,
          statusIconPadding: statusIconPadding,
          userAvatarImageBackgroundColor: userAvatarImageBackgroundColor,
          userAvatarNameColors: userAvatarNameColors,
          userAvatarTextStyle: userAvatarTextStyle,
          userNameTextStyle: userNameTextStyle,
        );
}
