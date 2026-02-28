import 'package:flutter/material.dart';

class Service {
  final String name;
  final Image img;
  final String description;
  final List<String> subServices;
  final List<String> subServicesImg;

  Service({
    required this.name,
    required this.img,
    required this.description,
    required this.subServices,
    required this.subServicesImg,
  });

  static List<Service> sampleServices = [
    Service(
      name: 'Home Maintenance',
      img: Image.network(
          'https://img.icons8.com/3d-fluency/94/home-automation.png'),
      description: 'Plumbing Repair & Installation',
      subServices: [
        'Electrician',
        'Carpenter',
        'Painting',
        'Plumber',
        'HVAC',
        'Pest Control',
        'Gardening',
      ],
      subServicesImg: [
        'https://img.icons8.com/external-soft-fill-juicy-fish/60/external-electrician-key-workers-soft-fill-soft-fill-juicy-fish.png',
        'https://img.icons8.com/3d-fluency/94/saw.png',
        'https://img.icons8.com/3d-fluency/94/roller-brush.png',
        'https://img.icons8.com/?size=100&id=xFN45rDF7HLr&format=png&color=000000',
        'https://img.icons8.com/fluency/48/heat-and-cool.png',
        'https://img.icons8.com/color/48/no-fly.png',
        'https://img.icons8.com/3d-fluency/94/garden.png',
      ],
    ),
    Service(
      name: 'Appliance Repair',
      img:
          Image.network('https://img.icons8.com/3d-fluency/94/maintenance.png'),
      description: 'Electrical Repair & Installation',
      subServices: [
        'Refrigerator Repair',
        'Washing Machine ',
        'Microwave & Oven Repair',
        'Television Repair',
      ],
      subServicesImg: [
        'https://img.icons8.com/3d-fluency/94/fridge.png',
        'https://img.icons8.com/3d-fluency/94/hdtv.png',
        'https://img.icons8.com/3d-fluency/94/washing-machine.png',
        'https://img.icons8.com/3d-fluency/94/cooker--v3.png',
      ],
    ),
    Service(
      name: 'Technology & IT',
      img:
          Image.network('https://img.icons8.com/3d-fluency/94/workstation.png'),
      description: 'Landscaping & Garden Maintenance',
      subServices: [
        ' Network Setup',
        'Smart Home Installation',
        'Computer Repairs',
      ],
      subServicesImg: [
        'https://img.icons8.com/3d-fluency/94/wi-fi-connected.png',
        'https://img.icons8.com/3d-fluency/94/smart-home.png',
        'https://img.icons8.com/3d-fluency/94/smartphone-tablet.png',
      ],
    ),
    Service(
      name: 'Personal & Lifestyle',
      img: Image.network('https://img.icons8.com/3d-fluency/94/welfare.png'),
      description: 'Landscaping & Garden Maintenance',
      subServices: [
        'Salon at Home',
        'Massage at Home',
        'Pet Care',
        'Tailoring & Alterations',
      ],
      subServicesImg: [
        'https://img.icons8.com/3d-fluency/94/barbershop.png',
        'https://img.icons8.com/emoji/96/person-getting-massage.png',
        'https://img.icons8.com/fluency/96/cat-caregivers.png',
        'https://img.icons8.com/fluency/96/sewing-machine.png',
      ],
    ),
    Service(
      name: 'Educational & Tutoring',
      img: Image.network('https://img.icons8.com/3d-fluency/94/reading.png'),
      description: 'Landscaping & Garden Maintenance',
      subServices: [
        'Mathematics',
        'Physics',
        'Chemistry',
        'Biology',
        'Languages',
        'History',
        'Computer Science',
        'Art & Design',
        'Drawing & Sketching',
        'Music & Performance',
      ],
      subServicesImg: [
        'https://img.icons8.com/3d-fluency/94/math.png',
        'https://img.icons8.com/3d-fluency/94/physics.png',
        'https://img.icons8.com/3d-fluency/94/molecule.png',
        'https://img.icons8.com/3d-fluency/94/biotech.png',
        'https://img.icons8.com/3d-fluency/94/language.png',
        'https://img.icons8.com/3d-fluency/94/scroll.png',
        'https://img.icons8.com/3d-fluency/94/science-fiction.png',
        'https://img.icons8.com/3d-fluency/94/easel.png',
        'https://img.icons8.com/fluency/94/grand-piano.png',
      ],
    ),
    Service(
      name: 'Event Support',
      img: Image.network('https://img.icons8.com/3d-fluency/94/confetti.png'),
      description: 'Landscaping & Garden Maintenance',
      subServices: [
        ' Security Services',
        'Photography & Videography',
        'Catering Services',
        'Decoration Services',
      ],
      subServicesImg: [
        'https://img.icons8.com/fluency/48/soldier.png',
        'https://img.icons8.com/3d-fluency/94/camera.png',
        'https://img.icons8.com/3d-fluency/94/tableware.png',
        'https://img.icons8.com/3d-fluency/94/party-baloons.png',
      ],
    ),
    Service(
      name: 'Cleaning',
      img: Image.network(
          'https://img.icons8.com/external-vitaliy-gorbachev-flat-vitaly-gorbachev/2x/external-cleaning-labour-day-vitaliy-gorbachev-flat-vitaly-gorbachev.png'),
      description: 'Home & Office Cleaning Services',
      subServices: [
        'General Cleaning',
        'Deep Cleaning',
        'Kitchen Cleaning',
        'Bathroom Cleaning',
        'Window Cleaning',
        'Carpet Cleaning',
      ],
      subServicesImg: [
        'https://img.icons8.com/3d-fluency/94/broom.png',
        'https://img.icons8.com/3d-fluency/94/washing-machine.png',
        'https://img.icons8.com/3d-fluency/94/cooker--v3.png',
        'https://img.icons8.com/3d-fluency/94/shower.png',
        'https://img.icons8.com/3d-fluency/94/window.png',
        'https://img.icons8.com/3d-fluency/94/vacuum-cleaner.png',
      ],
    ),
  ];
}
