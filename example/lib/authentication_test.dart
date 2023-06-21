import 'package:auth_management/core.dart';
import 'package:data_management/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthenticationTest extends StatefulWidget {
  const AuthenticationTest({Key? key}) : super(key: key);

  @override
  State<AuthenticationTest> createState() =>
      _AuthenticationTestState();
}

class _AuthenticationTestState extends State<AuthenticationTest> {
  late AuthController controller = context.read<AuthController>();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
              runSpacing: 12,
              spacing: 12,
              runAlignment: WrapAlignment.center,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  child: const Text("Availability"),
                  onPressed: () => controller.isAvailable("1"),
                ),
                ElevatedButton(
                  child: const Text("Insert"),
                  onPressed: () => controller.create(p1),
                ),
                ElevatedButton(
                  child: const Text("Inserts"),
                  onPressed: () => controller.creates([p1, p2]),
                ),
                ElevatedButton(
                  child: const Text("Update"),
                  onPressed: () {
                    controller.update(
                      id: p1.id,
                      data: p1.copyWith(price: 20500).source,
                    );
                  },
                ),
                ElevatedButton(
                  onPressed: () => controller.delete("1"),
                  child: const Text("Delete"),
                ),
                ElevatedButton(
                  onPressed: () => controller.clear(),
                  child: const Text("Clear"),
                ),
                ElevatedButton(
                  onPressed: () => controller.get("1"),
                  child: const Text("Get"),
                ),
                ElevatedButton(
                  onPressed: () => controller.gets(),
                  child: const Text("Gets"),
                ),
              ],
            ),
            BlocConsumer<AuthController, Response<User>>(
              builder: (context, state) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  color: Colors.grey.withAlpha(50),
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    state.toString(),
                    textAlign: TextAlign.center,
                  ),
                );
              },
              listener: (context, state) {
                if (state.isLoading) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.message),
                  ));
                } else if (state.isMessage) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.message),
                  ));
                } else if (state.isException) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.exception),
                  ));
                } else if (state.isValid) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Valid Data"),
                  ));
                } else if (state.isSuccessful) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Successful"),
                  ));
                } else if (state.isCancel) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Cancel"),
                  ));
                }
              },
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              color: Colors.grey.withAlpha(50),
              margin: const EdgeInsets.symmetric(vertical: 24),
              child: StreamBuilder(
                  stream: controller.live("1"),
                  builder: (context, snapshot) {
                    var value = snapshot.data ?? Response();
                    return Text(
                      value.data.toString(),
                      textAlign: TextAlign.center,
                    );
                  }),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              color: Colors.grey.withAlpha(50),
              margin: const EdgeInsets.symmetric(vertical: 24),
              child: StreamBuilder(
                stream: controller.lives(),
                builder: (context, snapshot) {
                  var value = snapshot.data ?? Response();
                  return Text(
                    value.result.toString(),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Step-5
/// Create a data controller for access all place
class AuthController extends DefaultAuthController<User> {
  AuthController({
    required super.handler,
  });
}

/// Step-4
/// When you complete the repository to use User model for locally or remotely
class ProductHandler extends RemoteDataHandlerImpl<User> {
  ProductHandler({
    required super.repository,
  });
}

/// Step-3
/// When you use to auto detected to use remote or local data
class ProductRepository extends RemoteDataRepositoryImpl<User> {
  ProductRepository({
    super.local,
    super.isCacheMode = true,
    required super.remote,
  });
}

/// Step - 2
/// When you use remote database (ex. Firebase Firestore, Firebase Realtime, Api, Encrypted Api data)
/// Use for remote data => insert, update, delete, get, gets, live, lives, clear
class RemoteProductDataSource extends FireStoreDataSourceImpl<User> {
  RemoteProductDataSource({
    super.path = "products",
  });

  @override
  User build(source) {
    return User.from(source);
  }
}

/// Step - 2
/// When you use local database (ex. SharedPreference)
/// Use for local data => insert, update, delete, get, gets, live, lives, clear
class LocalProductDataSource extends LocalDataSourceImpl<User> {
  LocalProductDataSource({
    required super.preferences,
    super.path = "products",
  });

  @override
  User build(source) {
    return User.from(source);
  }
}

/// Step - 1
/// Use for local or remote data model
class User extends AuthInfo {

  User({
    super.id,
    super.email,
    super.password,
    super.phone,
    super.provider,
    super.name,
    super.photo,
  });

  factory User.from(dynamic source) {
    return User(
      id: source.entityId,
      email: Entity.value<String>("email", source),
    );
  }

  User copyWith({
    String? id,
    int? timeMills,
    String? name,
    double? price,
  }) {
    return User(
      id: id ?? this.id,
      timeMills: timeMills ?? this.timeMills,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }

  @override
  Map<String, dynamic> get source {
    return super.source.attach({
      "name": name ?? "Name",
      "price": price,
    });
  }

  static List<User> get carts {
    return List.generate(5, (index) {
      return User(
        id: "ID${index + 1}",
        timeMills: Entity.ms,
        name: "Product - ${index + 1}",
        price: 45 + (index * 5),
      );
    });
  }
}