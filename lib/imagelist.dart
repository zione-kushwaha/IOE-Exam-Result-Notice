import 'package:flutter/material.dart';

List<Container> imagelist=[
 Container(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset('lib/assets/TU-Result.jpg',fit: BoxFit.cover,),
      ),
    ),
    Container(
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset('lib/assets/students.jpg',fit: BoxFit.cover,),
      ),
    ),
    Container(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset('lib/assets/download.jpeg',fit: BoxFit.cover,),
      ),
    ),
];