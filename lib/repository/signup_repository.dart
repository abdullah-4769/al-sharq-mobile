
import 'package:al_sharq_conference/utils/api_constants.dart';

import '../data/network/base_api_service.dart';
import '../data/request_models/sign_up_request_model.dart';

class SignupRepository {
  final _apiService = NetworkApiServices();

  Future<SignupResponseModel> register(SignupRequestModel data) async {
    final response = await _apiService.getPostApiServices(ApiConstants.signup, data.toJson());
    return SignupResponseModel.fromJson(response);
  }
}
