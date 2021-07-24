import 'appbar.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HisFinder',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void onItemTapped(int index) {
    // Bottom Bar 클릭 -> 페이지 이동
    setState(() {
      _selectedIndex = index;
    });
  }

  //현재 선택된 창 (bottom Bar)
  int _selectedIndex = 0;

  //하단 인디케이터
  bool isMoreRequesting = false;

  //데이터 가져올 때 페이지 구분
  int nextPage = 0;

  // 더미 데이터
  List<Data> serverItems = [];

  // 출력용 리스트
  List<Data> items = [];

  // 드레그 거리를 체크하기 위함
  // 해당 값을 평균내서 50%이상 움직였을때 데이터 불러오는 작업을 하게됨.
  double _dragDistance = 0;

  @override
  initState() {
    //서버의 가상데이터(더미 데이터) 추가 => backend system 에서는 지워도 됨.
    for (var i = 0; i < mydata.length; i++) {
      serverItems.add(mydata[i]);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                color: Color(0xff6990FF),
                height: MediaQuery.of(context).size.height / 2.7,
              ),
              Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height / 2.7,
              )
            ],
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 150.0,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification notification) {
                        /*
                         스크롤 할때 발생되는 이벤트
                         해당 함수에서 어느 방향으로 스크롤을 했는지를 판단해
                         리스트 가장 밑에서 아래서 위로 40프로 이상 스크롤 했을때
                         서버에서 데이터를 추가로 가져오는 루틴이 포함됨.
                        */
                        scrollNotification(notification);
                        return false;
                      },
                      child: RefreshIndicator(
                        /*
                         리스트에 위에서 아래로 스크롤 하게되면 onRefresh 이벤트 발생
                         서버에서 새로운(최신) 데이터를 가져오는 함수 구현
                        */
                        onRefresh: requestNew,
                        child: ListView.separated(
                          separatorBuilder: (BuildContext context, int index) {
                            return Container(
                                color: Colors.white, child: const Divider());
                          },
                          padding: const EdgeInsets.all(0),
                          itemBuilder: (context, int i) {
                            if (i == 0) // 0 번쨰 리스트
                              return HeaderTile(); // 검색창
                            else {
                              // 아니라면
                              switch (_selectedIndex) {
                                case 0: //  찾았어요
                                  return DataTile(items[i - 1]);
                                case 1: // 찾아요
                                  return DataTile(items[i - 1]);
                              }
                            }
                            return Container(height: 0);
                          },
                          /*
                           리스트의 데이터가 적어 스크롤이 생성되지 않아 스크롤 이벤트를 받을 수 없을수 있기 때문에 아래의 옵션을 추가함.
                           physics: AlwaysScrollableScrollPhysics()
                          */
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: items.length,
                        ),
                      ),
                    ),
                  ),
                ),
                /*
                 추가 데이터 가져올때 하단 효과 표시 용
                */
                Container(
                  height: isMoreRequesting ? 50.0 : 0,
                  color: Colors.white,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        //selectedIconTheme: I,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon:
                Image.asset("src/Found.png", width: 65, height: 65, scale: 2.5),
            //icon: Icon(Icons.business, size: 20),
            label: '주웠어요',
          ),
          BottomNavigationBarItem(
            icon:
                Image.asset("src/Lost.png", width: 65, height: 65, scale: 2.5),
            label: '찾아요',
          ),
          BottomNavigationBarItem(
            icon:
                Image.asset("src/Write.png", width: 65, height: 65, scale: 2.5),
            label: '글쓰기',
          ),
          BottomNavigationBarItem(
            icon:
                Image.asset("src/Chat.png", width: 65, height: 65, scale: 2.5),
            label: '채팅방',
          ),
          BottomNavigationBarItem(
            icon:
                Image.asset("src/Crang.png", width: 65, height: 65, scale: 2.5),
            label: '내계정',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xff6990FF),
        unselectedItemColor: Colors.black,
        selectedIconTheme: IconThemeData(color: Color(0xff6990FF)),
        onTap: onItemTapped,
        showUnselectedLabels: true,
        elevation: 10,

        backgroundColor: Colors.white,
      ),
    );
  }

  Future<void> requestNew() async {
    // 초기 데이터 세팅.

    nextPage = 0; // 현재 페이지
    items.clear(); // 리스트 초기화
    setState(() {
      items += serverItems.sublist(nextPage * 10, (nextPage * 10) + 10);
      nextPage += 1; // 다음을 위해 페이지 증가
    });

    // 데이터 가져오는 동안 효과를 보여주기 위해 약 1초간 대기하는 것
    // 실제 서버에서 가져올땐 필요없음
    return await Future.delayed(Duration(milliseconds: 1000));
  }

  //스크롤 이벤트 처리
  scrollNotification(notification) {
    // 스크롤 최대 범위
    var containerExtent = notification.metrics.viewportDimension;

    if (notification is ScrollStartNotification) {
      // 스크롤을 시작하면 발생(손가락으로 리스트를 누르고 움직이려고 할때)
      // 스크롤 거리값을 0으로 초기화함
      _dragDistance = 0;
    } else if (notification is OverscrollNotification) {
      //Android
      // 안드로이드에서 동작
      // 스크롤을 시작후 움직일때 발생(손가락으로 리스트를 누르고 움직이고 있을때 계속 발생)
      // 스크롤 움직인 만큼 빼준다.(notification.overscroll)
      _dragDistance -= notification.overscroll; //스크롤 하여 이동한 거리 계산
    } else if (notification is ScrollUpdateNotification) {
      // Ios
      // ios에서 동작
      // 스크롤을 시작후 움직일때 발생(손가락으로 리스트를 누르고 움직이고 있을때 계속 발생)
      // 스크롤 움직인 만큼 빼준다.(notification.scrollDelta)
      _dragDistance -= notification.scrollDelta!; //스크롤 하여 이동한 거리 계산
    } else if (notification is ScrollEndNotification) {
      // 스크롤이 끝났을때 발생(손가락을 리스트에서 움직이다가 뗐을때 발생)

      // 지금까지 움직인 거리를 최대 거리로 나눈다.
      var percent = _dragDistance / (containerExtent);

      // 해당 값이 -0.4(40프로 이상) 아래서 위로 움직였다면
      if (percent <= -0.0) {
        //Ios -> 0 android -> percent
        // maxScrollExtent는 리스트 가장 아래 위치 값
        // pixels는 현재 위치 값
        // 두 같이 같다면(스크롤이 가장 아래에 있다)
        if (notification.metrics.maxScrollExtent <=
            notification.metrics.pixels) {
          setState(() {
            isMoreRequesting = true; // 프로그래스 서클 활성화
          });

          requestMore().then((value) {
            // 서버에서 데이터 가져온다.
            setState(() {
              isMoreRequesting = false; //서클 비활성화
            });
          });
        }
      }
    }
  }

  Future<void> requestMore() async {
    //추가 데이터 셋팅
    // 해당부분  // 서버에서 추가 데이터 가져올 때은 서버에서 가져오는 내용을 가상으로 만든 것이기 때문에 큰 의미는 없다.
    // 읽을 데이터 위치 얻기
    int nextDataPosition = (nextPage * 10);
    // 읽을 데이터 크기
    int dataLength = 10; //가져올 데이터 크기

    if (nextDataPosition > serverItems.length) {
      // 더 이상 데이터가 없음.
      return;
    }
    if ((nextDataPosition + 10) > serverItems.length) {
      // 가져올 수 있는 데이터가 10개 미만
      dataLength = serverItems.length - nextDataPosition; // 가능한 최대 개수 얻기
    }
    await Future.delayed(Duration(milliseconds: 1000)); // 가상으로 잠시 지연 줌
    setState(() {
      items += serverItems.sublist(
          nextDataPosition, nextDataPosition + dataLength); // 데이터 읽기
      nextPage += 1; // 다음을 위해 페이지 증가
    });
    // return await Future.delayed(Duration(milliseconds: 1000)); // 가상으로 잠시 지연 줌
  }
}

class Data {
  //DataClass
  late String title; // 글 제목
  late String object; // 물품
  late bool isLost; // True => 찾아요 false => 잃어버렸어요
  late String location; // 장소
  late String time; // 습득일
  late Image image; // 사진
  Data(this.title, this.object, this.isLost, this.location,
      this.time); // TODO 글 쓴 시각 추가
}

List<Data> mydata = [
  // 더미데이터들
  Data("1", "가방", false, "뉴턴홀", "6월 1일"),
  Data("2", "가방", false, "뉴턴홀", "6월 1일"),
  Data("3", "가방", false, "뉴턴홀", "6월 1일"),
  Data("4", "가방", false, "뉴턴홀", "6월 1일"),
  Data("5", "가방", false, "뉴턴홀", "6월 1일"),
  Data("6", "가방", false, "뉴턴홀", "6월 1일"),
  Data("7", "가방", false, "뉴턴홀", "6월 1일"),
  Data("8", "가방", false, "뉴턴홀", "6월 1일"),
  Data("9", "가방", false, "뉴턴홀", "6월 1일"),
  Data("10", "가방", false, "뉴턴홀", "6월 1일"),
  Data("11", "가방", false, "뉴턴홀", "6월 1일"),
  Data("12", "가방", false, "뉴턴홀", "6월 1일"),
  Data("13", "가방", false, "뉴턴홀", "6월 1일"),
  Data("14", "가방", false, "뉴턴홀", "6월 1일"),
  Data("15", "가방", false, "뉴턴홀", "6월 1일"),
  Data("16", "가방", false, "뉴턴홀", "6월 1일"),
  Data("17", "가방", false, "뉴턴홀", "6월 1일"),
  Data("18", "가방", false, "뉴턴홀", "6월 1일"),
  Data("19", "가방", false, "뉴턴홀", "6월 1일"),
  Data("20", "가방", false, "뉴턴홀", "6월 1일"),
  Data("21", "가방", false, "뉴턴홀", "6월 1일"),
  Data("22", "가방", false, "뉴턴홀", "6월 1일"),
  Data("23", "가방", false, "뉴턴홀", "6월 1일"),
  Data("24", "가방", false, "뉴턴홀", "6월 1일"),
  Data("25", "가방", false, "뉴턴홀", "6월 1일"),
  Data("26", "가방", false, "뉴턴홀", "6월 1일"),
  Data("27", "가방", false, "뉴턴홀", "6월 1일"),
];

class HeaderTile extends StatelessWidget {
  //검색창 클래스
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 450,
        height: 50,
        color: Color(0xff6990FF),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 450,
              height: 30,
              color: Colors.white,
              child: TextFormField(
                style: TextStyle(
                    color: Colors.black, decorationColor: Colors.black),
                cursorColor: Colors.black,
              ),
            ),
          ),
        ));
  }
}

class DataTile extends StatelessWidget {
  // 데이터 생성 클래스
  final Data data;

  DataTile(this.data); // 데이터 받아오기

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListTile(
          leading: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: Icon(
              Icons.image,
              size: 50,
            ),
          ),
          title: Text(data.title),
          subtitle: Text((!data.isLost ? '습득한 물품 : ' : '분실한 물품 :') +
              data.object +
              '\n\n장소 : ' +
              data.location +
              '\n습득일 : ' +
              data.time),
          trailing: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            Text(
              '2021년 6월 2일',
              //TODO 날자 데이터 받아오기
              textScaleFactor: 0.7,
              style: TextStyle(color: Colors.black54),
            ),
          ]),
          onTap: () {
            // click action
          }),
    );
  }
}

//
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'appbar.dart';
//
// void main() => runApp(const MyApp());
//
// /// This is the main application widget.
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   static const String _title = 'HisFinder';
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       title: _title,
//       debugShowCheckedModeBanner: false,
//       home: MyStatefulWidget(),
//     );
//   }
// }
//
// class MyStatefulWidget extends StatefulWidget {
//   const MyStatefulWidget({Key? key}) : super(key: key);
//
//   @override
//   State<MyStatefulWidget> createState() => MyStatefulWidgetState();
// }
//
// class MyStatefulWidgetState extends State<MyStatefulWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AlarmAppBar(),
//       body: BodyWidget(),
//     );
//   }
// }
//
// class HeaderTile extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         width: 450,
//         height: 50,
//         color: Color(0xff6990FF),
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Container(
//               width: 450,
//               height: 30,
//               color: Colors.white,
//               child: TextFormField(
//                 style: TextStyle(
//                     color: Colors.black, decorationColor: Colors.black),
//                 cursorColor: Colors.black,
//               ),
//             ),
//           ),
//         ));
//   }
// }
//
// class Data {
//   late String title; // 글 제목
//   late String object; // 물품
//   late bool isLost; // True => 찾아요 false => 잃어버렸어요
//   late String location; // 장소
//   late String time; // 습득일
//   late Image image; // 사진
//   Data(this.title, this.object, this.isLost, this.location, this.time);
// }
//
// List<Data> mydata = [
//   Data("가방 찾아가세요!!!", "가방", false, "뉴턴홀", "6월 1일"),
//   Data("가방, 신발 찾아가세요!!!", "가방, 신발", false, "뉴턴홀", "6월 1일"),
//   Data("가방 찾아가세요!!!", "가방", false, "뉴턴홀", "6월 1일"),
//   Data("가방 찾아가세요!!!", "가방", false, "뉴턴홀", "6월 1일"),
//   Data("가방 찾아가세요!!!", "가방", false, "뉴턴홀", "6월 1일"),
//   Data("가방 찾아가세요!!!", "가방", false, "뉴턴홀", "6월 1일"),
//   Data("가방 찾아가세요!!!", "가방", false, "뉴턴홀", "6월 1일"),
//   Data("신발 찾아가세요!!!", "신발", false, "뉴턴홀", "6월 1일"),
//   Data("신발 찾아가세요!!!", "신발", false, "뉴턴홀", "6월 1일"),
//   Data("신발 찾아가세요!!!", "신발", false, "뉴턴홀", "6월 1일"),
//   Data("신발 찾아가세요!!!", "신발", false, "뉴턴홀", "6월 1일"),
//   Data("신발 찾아가세요!!!", "신발", false, "뉴턴홀", "6월 1일"),
//   Data("신발 찾아가세요!!!", "신발", false, "뉴턴홀", "6월 1일"),
//   Data("신발 찾아가세요!!!", "신발", false, "뉴턴홀", "6월 1일"),
//   Data("신발 찾아가세요!!!", "신발", false, "뉴턴홀", "6월 1일"),
//   Data("신발 찾아가세요!!!", "신발", false, "뉴턴홀", "6월 1일"),
//   Data("신발 찾아가세요!!!", "신발", false, "뉴턴홀", "6월 1일"),
// ];
//
// class DataTile extends StatelessWidget {
//   final Data data;
//
//   DataTile(this.data);
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           color: Colors.white,
//           child: ListTile(
//             leading: Padding(
//               padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
//               child: Icon(
//                 Icons.image,
//                 size: 50,
//               ),
//             ),
//             title: Text(data.title),
//             subtitle: Text((!data.isLost ? '습득한 물품 : ' : '분실한 물품 :') +
//                 data.object +
//                 '\n\n장소 : ' +
//                 data.location +
//                 '\n습득일 : ' +
//                 data.time),
//             trailing:
//                 Column(mainAxisAlignment: MainAxisAlignment.end, children: [
//               Text(
//                 '2021년 6월 2일',
//                 textScaleFactor: 0.7,
//                 style: TextStyle(color: Colors.black54),
//               ),
//             ]),
//             onTap: () {
//               // click action
//             },
//           ),
//         ),
//         Divider()
//       ],
//     );
//   }
// }
//
// class _BodyWidget extends State<BodyWidget> {
//   List<Data> keywordData = <Data>[];
//   List<String> keyword = <String>[];
//   String listString = '';
//
//   @override
//   Widget build(BuildContext context) {
//     keyword = <String>[]; // 키워드 리스트
//     keywordData = <Data>[]; // 검색 범위
//
//     //---------------------------------
//     // get DataList
//     keywordData = mydata;
//     //---------------------------------
//
//     //---------------------------------
//     // get keywords
//     keyword.add('가방');
//     keyword.add('신발');
//     keyword.add('지갑');
//
//     // set keywords list
//     listString = '';
//     for (int i = 0; i < keyword.length; i++) {
//       if (i != 0) listString += (', ');
//       listString += (" '" + keyword[i] + "'");
//     }
//     //---------------------------------
//     int index = 0; // data index
//     int keyIndex = 0; // keyword index
//     List<Data> outList = []; // [index]
//     //---------------------------------
//     // 구현전용 검색 알고리즘
//     for (int l = 0; l < keywordData.length; l++)
//       for (int k = 0; k < keyword.length; k++)
//         if (keywordData[l].title.contains(keyword[k]))
//           outList.add(keywordData[l]);
//     //---------------------------------
//     // 키워드 지정 없을시
//     if (keyword.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(
//               'src/CrangKeyword.png',
//               scale: 3.5,
//             ),
//             Container(
//               margin: EdgeInsets.only(top: 40),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.all(
//                   Radius.circular(10),
//                 ),
//                 border: Border.all(
//                   color: Colors.black,
//                   width: 1,
//                 ),
//               ),
//               child: Container(
//                   margin: EdgeInsets.all(5),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.all(
//                       Radius.circular(10),
//                     ),
//                     // border 꾸미기
//                     border: Border.all(
//                       color: Colors.black,
//                       width: 1,
//                     ),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       '새로운 알림이 없어요\n 알람을 받고 싶은 키워드를 설정해보세요',
//                       textAlign: TextAlign.center,
//                     ),
//                   )),
//             )
//           ],
//         ),
//       );
//     }
//     //---------------------------------
//     else {
//       return ListView.builder(
//           padding: const EdgeInsets.all(0),
//           itemCount: 10,
//           itemBuilder: (context, int i) {
//             String n = '';
//             for (int k = 0; k < keyword.length; k++)
//               if (keywordData[i].title.contains(keyword[k])) {
//                 if (n != '') n += ', ';
//                 n += ("'" + keyword[k] + "'");
//               }
//             if (i == 0) {
//               i--;
//               return Container(
//                   padding: EdgeInsets.all(10),
//                   child: Text(
//                     '설정 키워드 : ' + listString,
//                     textScaleFactor: 1.3,
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ));
//             } else {
//               return Column(
//                   //mainAxisAlignment: MainAxisAlignment.end,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       color: Colors.white,
//                       padding: EdgeInsets.only(left: 10),
//                       child: Text(
//                         n,
//                         textScaleFactor: 1.3,
//                         textAlign: TextAlign.left,
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     Container(color: Colors.white,child: Divider()),
//                     DataTile(outList[i])
//                   ]);
//             }
//           });
//     }
//   }
// }
//
// class BodyWidget extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _BodyWidget();
// }
//
// //---------------------------------------------------------------------
