part of 'models.dart';

class Credential {
  final String? accessToken;
  final OAuthCredential? credential;
  final String? email;
  final String? id;
  final String? idToken;
  final String? name;
  final String? photo;

  const Credential({
    this.accessToken,
    this.credential,
    this.id,
    this.idToken,
    this.email,
    this.name,
    this.photo,
  });

  factory Credential.fromMap(Map<String, dynamic> map) {
    String? id = map['id'];
    String? email = map['email'];
    String? name = map['name'];
    String? photo;
    try {
      photo = map['picture']['data']['url'];
    } catch (_) {
      photo = '';
    }
    return Credential(
      id: id,
      email: email,
      name: name,
      photo: photo,
    );
  }

  Credential copy({
    String? accessToken,
    OAuthCredential? credential,
    String? id,
    String? idToken,
    String? name,
    String? email,
    String? photo,
  }) {
    return Credential(
      accessToken: accessToken ?? this.accessToken,
      credential: credential ?? this.credential,
      id: id ?? this.id,
      idToken: idToken ?? this.idToken,
      email: email ?? this.email,
      name: name ?? this.name,
      photo: photo ?? this.photo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "accessToken": accessToken,
      "credential": credential,
      "id": id,
      "idToken": idToken,
      "email": email,
      "name": name,
      "photo": photo,
    };
  }
}
