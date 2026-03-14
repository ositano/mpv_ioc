// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/enums.dart';
import '../../repository/post_detail_repository.dart';
import '../managers/post_detail_manager.dart';

part 'post_detail_state.dart';

class PostDetailCubit extends Cubit<PostDetailState> {
  final PostDetailManager manager;
  final PostDetailRepository repository;

  PostDetailCubit({required this.manager, required this.repository})
      : super(const PostDetailInitial()) {
    manager.onLoad = _loadPost;
    _loadPost();
  }

  Future<void> _loadPost() async {
    final id = manager.post.value?.id;
    if (id == null) return;
    emit(const PostDetailLoading());
    manager.requestStatus.value = RequestStatus.loading;
    final result = await repository.getPost(id);
    result.fold(
      (f) {
        manager.requestStatus.value = RequestStatus.error;
        manager.showUiMessage(f.failureMessage());
        emit(PostDetailError(f.failureMessage()));
      },
      (r) {
        manager.post.value = r.data;
        manager.requestStatus.value = RequestStatus.loaded;
        emit(const PostDetailLoaded());
      },
    );
  }

  @override
  Future<void> close() { manager.dispose(); return super.close(); }
}
