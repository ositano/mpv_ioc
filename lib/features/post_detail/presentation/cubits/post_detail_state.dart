// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)

part of 'post_detail_cubit.dart';
abstract class PostDetailState { const PostDetailState(); }
class PostDetailInitial extends PostDetailState { const PostDetailInitial(); }
class PostDetailLoading extends PostDetailState { const PostDetailLoading(); }
class PostDetailLoaded  extends PostDetailState { const PostDetailLoaded();  }
class PostDetailError   extends PostDetailState {
  final String message;
  const PostDetailError(this.message);
}
