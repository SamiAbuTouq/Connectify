import 'package:flutter/material.dart';

class Service {
  final String name;
  final Image img;
  final String description;
  final List<String> subServices;

  Service({
    required this.name,
    required this.img,
    required this.description,
    required this.subServices,
  });

  static List<Service> sampleServices = [
    Service(
      name: 'Home Maintenance',
      img: Image.network(
          'https://img.icons8.com/3d-fluency/94/home-automation.png'),
      description: 'Plumbing Repair & Installation',
      subServices: [
        'Pipe Repair',
        'Water Heater Installation',
        'Drain Cleaning',
        'Faucet Repair'
      ],
    ),
    Service(
      name: 'Appliance Repair',
      img:
          Image.network('https://img.icons8.com/3d-fluency/94/maintenance.png'),
      description: 'Electrical Repair & Installation',
      subServices: [
        'Fix Air Conditioner',
        'Fix Air Fryer',
        'Fix Refrigerator',
        'Fix Lighting',
        'Fix Power Outlets',
        'Wiring Installation'
      ],
    ),
    Service(
      name: 'Technology & IT',
      img:
          Image.network('https://img.icons8.com/3d-fluency/94/workstation.png'),
      description: 'Landscaping & Garden Maintenance',
      subServices: [
        'Lawn Mowing',
        'Plant Installation',
        'Tree Trimming',
        'Garden Design'
      ],
    ),
    Service(
      name: 'Personal & Lifestyle',
      img: Image.network('https://img.icons8.com/3d-fluency/94/welfare.png'),
      description: 'Landscaping & Garden Maintenance',
      subServices: [
        'Lawn Mowing',
        'Plant Installation',
        'Tree Trimming',
        'Garden Design'
      ],
    ),
    Service(
      name: 'Educational & Tutoring',
      img: Image.network('https://img.icons8.com/3d-fluency/94/reading.png'),
      description: 'Landscaping & Garden Maintenance',
      subServices: [
        'Lawn Mowing',
        'Plant Installation',
        'Tree Trimming',
        'Garden Design'
      ],
    ),
    Service(
      name: 'Event Support',
      img: Image.network('https://img.icons8.com/3d-fluency/94/confetti.png'),
      description: 'Landscaping & Garden Maintenance',
      subServices: [
        'Lawn Mowing',
        'Plant Installation',
        'Tree Trimming',
        'Garden Design'
      ],
    ),
    Service(
      name: 'Cleaning',
      img: Image.network(
          'https://img.icons8.com/external-vitaliy-gorbachev-flat-vitaly-gorbachev/2x/external-cleaning-labour-day-vitaliy-gorbachev-flat-vitaly-gorbachev.png'),
      description: 'Landscaping & Garden Maintenance',
      subServices: [
        'Lawn Mowing',
        'Plant Installation',
        'Tree Trimming',
        'Garden Design'
      ],
    ),
  ];
}
