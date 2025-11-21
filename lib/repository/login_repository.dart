// lib/repository/login_repository.dart

import 'package:al_sharq_conference/data/network/base_api_service.dart';
import 'package:al_sharq_conference/utils/api_constants.dart';

import '../data/request_models/login_request_model.dart';
import '../data/response_models/login_response_model.dart';

class LoginRepository {
  final _apiService = NetworkApiServices();

  Future<LoginResponseModel> login(LoginRequestModel data) async {
    final response = await _apiService.getPostApiServices(
      ApiConstants.login,
      data.toJson(),
    );
    return LoginResponseModel.fromJson(response);
  }
}