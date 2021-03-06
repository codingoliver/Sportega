import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:sportega/services/api/photo_repo.dart';
import 'package:sportega/ui/components/offline.dart';
import 'package:sportega/ui/components/photo/photo_list.dart';
import 'package:sportega/ui/components/progress.dart';
import 'package:sportega/ui/components/server_error.dart';
import 'package:sportega/ui/constants/load_data_status.dart';
import 'package:sportega/ui/holders/photo.dart';
import 'package:sportega/ui/routes/routes.dart';

class PhotoTab extends StatefulWidget {
  final Function onGoToFavoriteButtonClicked;

  const PhotoTab({@required Key key, this.onGoToFavoriteButtonClicked})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PhotoTabState();
}

class _PhotoTabState extends State<PhotoTab> {
  // load data status
  LoadDataStatus _loadDataStatus;

  // state
  List<Photo> photoList = [];

  @override
  void initState() {
    super.initState();
    this._loadData();
  }

  void _loadData() {
    // returns true if tab state data is present and was loaded successfully
    if (this._initializeTabStateData()) {
      return;
    }

    // show progress indicator
    this.setState(() => this._loadDataStatus = LoadDataStatus.loading);

    PhotoRepo().getPhotos().then((photos) {
      this.setState(() {
        this.photoList = photos;
        this._loadDataStatus = LoadDataStatus.success;

        // save tab state data
        this._saveTabStateData(LoadDataStatus.success, photos);
      });
    }).catchError((error) {
      this.setState(() {
        this._loadDataStatus = error is SocketException
            ? LoadDataStatus.offline
            : LoadDataStatus.serverError;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return this._content(context);
  }

  Widget _content(BuildContext context) {
    switch (this._loadDataStatus) {
      case LoadDataStatus.success:
        return this._getPhotosWidget(context);
      case LoadDataStatus.offline:
        return this._getOfflineWidget();
      case LoadDataStatus.serverError:
        return this._getServerErrorWidget();
      default:
        return Progress();
    }
  }

  // photos grid list widget
  Widget _getPhotosWidget(BuildContext context) {
    return PhotoList(
      photoList: this.photoList,
      onItemSelected: (position) =>
          Routes().navigateToPhotoPage(context, this.photoList[position]),
    );
  }

  // offline widget
  Widget _getOfflineWidget() {
    return Offline(
      image: 'assets/images/offline.png',
      title: 'You are Offline',
      subTitle: 'Read news items you saved in your favorites folder',
      buttonTitle: 'Go to Favorites',
      onButtonClicked: () => this.widget.onGoToFavoriteButtonClicked(),
      onRetryClicked: () => this._loadData(),
    );
  }

  // offline widget
  Widget _getServerErrorWidget() {
    return ServerError(
      image: 'assets/images/server_error.png',
      title: 'Oops! It\'s not you, it\'s us',
      subTitle: 'A server error was encountered when loading the data',
      onRetryClicked: () => this._loadData(),
    );
  }

  void _saveTabStateData(LoadDataStatus success, List<Photo> photos) {
    this._loadDataStatus = LoadDataStatus.success;
    PageStorage.of(this.context).writeState(context, LoadDataStatus.success,
        identifier: ValueKey('PhotoLoadDataStatusState'));
    PageStorage.of(this.context).writeState(context, photos,
        identifier: ValueKey('PhotoTabPhotoListState'));
  }

  // returns true if tab state data is present and was loaded successfully
  bool _initializeTabStateData() {
    // load tab state data if present
    var loadDataStatusState = PageStorage.of(this.context)?.readState(
        this.context,
        identifier: ValueKey('PhotoLoadDataStatusState'));
    if (loadDataStatusState != null &&
        loadDataStatusState == LoadDataStatus.success) {
      this.setState(() {
        this._loadDataStatus = LoadDataStatus.success;
        this.photoList = PageStorage.of(this.context)?.readState(this.context,
            identifier: ValueKey('PhotoTabPhotoListState'));
      });
      return true;
    }

    return false;
  }
}
