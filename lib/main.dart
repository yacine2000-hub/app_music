import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'musique.dart';
import 'package:audioplayer/audioplayer.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,//Enlever le Debug en haut de la barre
      title: 'App Music',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'App Music'),
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Musique> maListeDeMusiques = [//liste de musique
    new Musique('Nop Naala','Fatma','images/fatma.jpg','https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3'),
    new Musique('Naguoulma','Viviane','images/viviane.jpg','https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.mp3'),
    new Musique('Wurus','Wally','images/wally.jpg','https://dl.espressif.com/dl/audio/ff-16b-1c-44100hz.mp3'),
  ];
  //MES VARIABLES
  late StreamSubscription positionSub;
  late StreamSubscription stateSubscription;
  late AudioPlayer audioPlayer;//un audio player a 3 etats soit il marche soit il est pause soit il ne marche op ou stopper
  //AudioPlayer audioPlugin = AudioPlayer();
  late Musique maMusiqueActuelle;
   Duration position  = new Duration(seconds:0);
   Duration duree = new Duration(seconds:10);
   PlayerState statut = PlayerState.stopped;
  @override
  void initState()  //C'est quand l'etat va etre  initialiser ctd kan on va initialiser notre widgets 
  {
    super.initState();
    maMusiqueActuelle = maListeDeMusiques[0];//C'est lorsqu'on va faire un initstate notre musique soit la premiere music
    configurationAudioPlayer();
  }  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,//centrer le titre du menu
        backgroundColor: Colors.grey[900],//Couleur du appbar
        title: Text(widget.title),
      ),
      backgroundColor: Colors.grey[800],//Couleur du Scafold
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Card(
              elevation: 9.0,
              child: new Container(
                width: MediaQuery.of(context).size.height /2.5,//pour que mon image fait le moin de la motier
                child: new Image.asset(maMusiqueActuelle.imagePath),
              ),
            ),
            textAvecStyle(maMusiqueActuelle.titre, 1.5),
            textAvecStyle(maMusiqueActuelle.artiste, 1.0),
            new Row(//pour les boutton
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                mesBoutons(Icons.fast_rewind,30.0,ActionMusic.rewind) ,
                mesBoutons((statut == PlayerState.playing)?Icons.pause:Icons.play_arrow,45.0, (statut==PlayerState.playing) ? ActionMusic.pause : ActionMusic.play),
                mesBoutons(Icons.fast_forward,30.0,ActionMusic.forward),

              ],
            ),
            new Row(//Pour le temps du son
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                textAvecStyle('0:0', 0.8),
                textAvecStyle('0:22', 0.8),
              ],
            ),
            new Slider(//C'est la barre qui nous permet a avncer la music ou le reculer
                value: position.inSeconds.toDouble(),
                min:0.0,
                max:30.0,
                inactiveColor: Colors.white,
                activeColor: Colors.red,
                onChanged:(double d) {
                  setState(() {
                    Duration nouvelleDuration = new Duration(seconds: d.toInt());
                    position = nouvelleDuration;
                  });
                }),
          ],
        ),
      ),
    );
  }
  IconButton mesBoutons(IconData icone,double taille,ActionMusic action)
  {
      return new IconButton(
        iconSize:taille,
        color:Colors.white,
        icon: new Icon(icone),
        onPressed: ()
        {
          switch(action)
          {
            case ActionMusic.play:
              play();
              break;
            case ActionMusic.pause:
              pause() ;
              break;
            case ActionMusic.rewind:
              print('Rewind') ;
              break;
            case ActionMusic.forward:
              print('Forward');
            break;
          }
        },
      );
  }
  Text textAvecStyle(String data,double scale)//cette fonction permet d'ajoute un texte
  {
    return new Text(
      data,
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: new TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontStyle: FontStyle.italic,
      ),
    );
  }
  void configurationAudioPlayer()
  {
    audioPlayer = new AudioPlayer();
    positionSub = audioPlayer.onAudioPositionChanged.listen((pos) => setState(()=>position = pos));
    stateSubscription = audioPlayer.onPlayerStateChanged.listen((state){
      if(state == AudioPlayerState.PLAYING)
      {
        setState(() {
          duree = audioPlayer.duration;
        });
      } else if(state == AudioPlayerState.STOPPED)
        {
          setState(() {
            statut = PlayerState.stopped;
          });
        }
    },onError: (message)
        {
          print('Erreur : $message');
          setState(() {
            statut = PlayerState.stopped;
            duree = new Duration(seconds: 0);
            position = new Duration(seconds: 0);
          });
        }
    );//onAudioPositionChanged c'est quand la position de l'audioplayer a changer
  }
  Future play() async//parce qu'il va attendre que la musique soit jouer
  {
    await audioPlayer.play(maMusiqueActuelle.urlSong);
    statut = PlayerState.playing;
  }
  Future pause() async
      {
    await audioPlayer.pause();
    statut = PlayerState.paused;
  }
}
enum ActionMusic
{
  play,
  pause,
  rewind,
  forward
}
enum PlayerState//Pour voir l'etat de mon audio player pour voir s'il est active ou non
{
  playing,
  stopped,
  paused
}