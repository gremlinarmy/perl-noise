#!/usr/bin/perl

use v5.14;
use Audio::PortAudio;
use Coro::Generator;
use List::Util qw( sum );
use List::MoreUtils qw( none );

my $sample_rate = 48000;
# my $sample_rate = 44100;
# my $sample_rate = 24000;
my $time_step = (1/$sample_rate); # 2 * (1/48000) = 0.0000416666
my $pi = 3.14159265358979323846;

my $api = Audio::PortAudio::default_host_api();
my $device  = $api->default_output_device;

my $stream = $device->open_write_stream( {
    channel_count => 1,
  },
  $sample_rate,
  1000, # some sort of buffer size?
  0
);

# Note => Frequency (Hz)
my %note = (
  'C0'  => 16.35,
  'C#0' => 17.32,
  'Db0' => 17.32,
  'D0'  => 18.35,
  'D#0' => 19.45,
  'Eb0' => 19.45,
  'E0'  => 20.60,
  'F0'  => 21.83,
  'F#0' => 23.12,
  'Gb0' => 23.12,
  'G0'  => 24.50,
  'G#0' => 25.96,
  'Ab0' => 25.96,
  'A0'  => 27.50,
  'A#0' => 29.14,
  'Bb0' => 29.14,
  'B0'  => 30.87,
  'C1'  => 32.70,
  'C#1' => 34.65,
  'Db1' => 34.65,
  'D1'  => 36.71,
  'D#1' => 38.89,
  'Eb1' => 38.89,
  'E1'  => 41.20,
  'F1'  => 43.65,
  'F#1' => 46.25,
  'Gb1' => 46.25,
  'G1'  => 49.00,
  'G#1' => 51.91,
  'Ab1' => 51.91,
  'A1'  => 55.00,
  'A#1' => 58.27,
  'Bb1' => 58.27,
  'B1'  => 61.74,
  'C2'  => 65.41,
  'C#2' => 69.30,
  'Db2' => 69.30,
  'D2'  => 73.42,
  'D#2' => 77.78,
  'Eb2' => 77.78,
  'E2'  => 82.41,
  'F2'  => 87.31,
  'F#2' => 92.50,
  'Gb2' => 92.50,
  'G2'  => 98.00,
  'G#2' => 103.83,
  'Ab2' => 103.83,
  'A2'  => 110.00,
  'A#2' => 116.54,
  'Bb2' => 116.54,
  'B2'  => 123.47,
  'C3'  => 130.81,
  'C#3' => 138.59,
  'Db3' => 138.59,
  'D3'  => 146.83,
  'D#3' => 155.56,
  'Eb3' => 155.56,
  'E3'  => 164.81,
  'F3'  => 174.61,
  'F#3' => 185.00,
  'Gb3' => 185.00,
  'G3'  => 196.00,
  'G#3' => 207.65,
  'Ab3' => 207.65,
  'A3'  => 220.00,
  'A#3' => 233.08,
  'Bb3' => 233.08,
  'B3'  => 246.94,
  'C4'  => 261.63,
  'C#4' => 277.18,
  'Db4' => 277.18,
  'D4'  => 293.66,
  'D#4' => 311.13,
  'Eb4' => 311.13,
  'E4'  => 329.63,
  'F4'  => 349.23,
  'F#4' => 369.99,
  'Gb4' => 369.99,
  'G4'  => 392.00,
  'G#4' => 415.30,
  'Ab4' => 415.30,
  'A4'  => 440.00,
  'A#4' => 466.16,
  'Bb4' => 466.16,
  'B4'  => 493.88,
  'C5'  => 523.25,
  'C#5' => 554.37,
  'Db5' => 554.37,
  'D5'  => 587.33,
  'D#5' => 622.25,
  'Eb5' => 622.25,
  'E5'  => 659.26,
  'F5'  => 698.46,
  'F#5' => 739.99,
  'Gb5' => 739.99,
  'G5'  => 783.99,
  'G#5' => 830.61,
  'Ab5' => 830.61,
  'A5'  => 880.00,
  'A#5' => 932.33,
  'Bb5' => 932.33,
  'B5'  => 987.77,
  'C6'  => 1046.50,
  'C#6' => 1108.73,
  'Db6' => 1108.73,
  'D6'  => 1174.66,
  'D#6' => 1244.51,
  'Eb6' => 1244.51,
  'E6'  => 1318.51,
  'F6'  => 1396.91,
  'F#6' => 1479.98,
  'Gb6' => 1479.98,
  'G6'  => 1567.98,
  'G#6' => 1661.22,
  'Ab6' => 1661.22,
  'A6'  => 1760.00,
  'A#6' => 1864.66,
  'Bb6' => 1864.66,
  'B6'  => 1975.53,
  'C7'  => 2093.00,
  'C#7' => 2217.46,
  'Db7' => 2217.46,
  'D7'  => 2349.32,
  'D#7' => 2489.02,
  'Eb7' => 2489.02,
  'E7'  => 2637.02,
  'F7'  => 2793.83,
  'F#7' => 2959.96,
  'Gb7' => 2959.96,
  'G7'  => 3135.96,
  'G#7' => 3322.44,
  'Ab7' => 3322.44,
  'A7'  => 3520.00,
  'A#7' => 3729.31,
  'Bb7' => 3729.31,
  'B7'  => 3951.07,
  'C8'  => 4186.01,
  'C#8' => 4434.92,
  'Db8' => 4434.92,
  'D8'  => 4698.64,
  'D#8' => 4978.03,
  'Eb8' => 4978.03,
);

# Play a sequence until we get an undef
sub play {
  my $gen = shift;
  while (1) {
    my $raw_sample = '';
    for(1..1000) {
    # while(1) {
      my $sample = $gen->();
      if($sample > 1 || $sample < -1) {
        print "CLIP: $sample\n";
        $sample = $sample > 1 ? 1 : -1;
      }
      # print "Sample: $sample\n";
      if(!defined $sample) {
        $stream->write($raw_sample);
        return;
      }
        
      $raw_sample .= pack "f*", $sample;
    }
    # print "Sending sample block...";
    $stream->write($raw_sample);
    # print "sent.\n";
  }
}

sub beep_gen {
  my ($freq, $length, $volume) = @_;
  $volume ||= 0.9;
  my $sample_count = $length * $sample_rate;
  my $current_sample = 0;
  return generator {
    while ($current_sample < $sample_count) {
      my $sample = sin( $time_step * $pi * $current_sample * 2 * $freq ) * (1 - ($current_sample / $sample_count)) * $volume;
      yield($sample);
      $current_sample++;
    }
    yield(undef);
    $current_sample = 0; # begin again!
    # print "Sending undef\n";
    # yield(undef) while 1;
  };
}

sub sine_gen {
  my ($freq, $volume) = @_;
  $volume ||= 0.9;
  return sub {
    state $current_sample //= 0;
    my $sample =
      sin( $time_step * $pi * $current_sample * 2 * $freq )
      * $volume;
    $current_sample++;
    return $sample;
  };
}

sub silence_gen {
  return sub {
    return 0;
  };
}

sub noise_gen {
  my ($freq, $volume) = @_;
  return sub {
    return $volume * (rand(2) - 1);
  };
}

sub saw_gen {
  my ($freq, $volume) = @_;
  $volume ||= 0.9;
  my $sample_count = (1 / $freq) * $sample_rate;
  return sub {
    state $current_sample //= 0;
    state $current_freq //= 0;
    state $direction = 1;
    my $sample = $current_freq;
    $current_freq += $direction * (4 / $sample_count);
    if($current_freq >= 1) {
      $current_freq = 1;
      $direction = -1;
    }
    if($current_freq <= -1) {
      $current_freq = -1;
      $direction = 1;
    }
    return $current_freq * $volume;
  };
}

sub square_gen {
  my ($freq, $volume) = @_;
  $volume ||= 0.9;
  my $sample_count = (1 / $freq) * $sample_rate;
  return sub {
    state $current_sample //= 0;
    state $current_freq //= 0;
    state $direction = 1;
    $current_sample++;
    if($current_sample > $sample_count) {
      $current_sample = 1;
    }
    if($current_sample < $sample_count / 2) {
      return $volume;
    }
    if($current_sample >= $sample_count / 2) {
      return $volume * -1;
    }
  };
}


sub envelope_gen {
  my ($gen, $attack, $sustain, $release) = @_;

  my $attack_sample_count  = $attack * $sample_rate;
  my $sustain_sample_count = $sustain * $sample_rate;
  my $release_sample_count = $release * $sample_rate;

  return sub {
    state $mode //= 'attack';
    state $current_sample //= 0;
    $current_sample++;
    if($mode eq 'attack') {
      if($current_sample > $attack_sample_count) {
        $current_sample = 1;
        $mode = 'sustain';
      } else {
        my $scale = $current_sample / $attack_sample_count;
        return $gen->() * $scale;
      }
    }
    if($mode eq 'sustain') {
      if($current_sample > $sustain_sample_count) {
        $current_sample = 1;
        $mode = 'release';
      } else {
        return $gen->();
      }
    }
    if($mode eq 'release') {
      if($current_sample > $release_sample_count) {
        $current_sample = 1;
        $mode = 'attack';
        return undef;
      } else {
        my $scale = 1 - ($current_sample / $release_sample_count);
        return $gen->() * $scale;
      }
    }
  };
}

sub combine_gen {
  my (@gens) = @_;
  return sub {
    state @g;
    (@g) = @gens unless @g;
    my @samples = map { $_->() } @g;
    if(none { defined } @samples) {
      (@g) = @gens;
      return undef;
    } else {
      my $sample = sum @samples;
      return $sample;
    }
  };
}

sub sequence_gen {
  my (@gens) = @_;
  return sub {
    state @g;
    (@g) = @gens unless @g;
    while(@g) {
      my $sample = $g[0]->();
      if(defined $sample) {
        return $sample;
      } else {
        shift @g;
      }
    }
    (@g) = @gens;
    return undef;
  };
}

sub note_gen {
  my ($note, $attack, $sustain, $release) = @_;
  $attack //= 0.1;
  $sustain //= 0.1;
  $release //= 0.1;
  my $c = sine_gen($note{$note}, 0.1);
  # my $c = saw_gen($note{$note}, 0.1);
  # my $c = square_gen($note{$note}, 0.1);
  # my $c = noise_gen($note{$note}, 0.1);
  $c = envelope_gen( $c, $attack, $sustain, $release);
  return $c;
}

sub rest_gen {
  my ($length) = @_;
  my $silence = silence_gen();
  return envelope_gen( $silence, 0, $length, 0);
}

# my $c = sine_gen($note{'C4'}, 0.5, 0.3);
# $c = envelope_gen( $c, 0.1, 0.1, 0.1 );
# my $e = sine_gen($note{'E4'}, 0.5, 0.3);
# my $g = sine_gen($note{'G4'}, 0.5, 0.3);

# my $c = note_gen('C4');
# my $e = note_gen('E4');
# my $g = note_gen('G4');
# my $seq = sequence_gen($c, $e, $g);
# play($seq);
# play($seq);

# we can re-use $c, $e, and $g
#my $chord = combine_gen($c, $e, $g);
# my $chord =
  # envelope_gen(
    # combine_gen(
      # #map { sine_gen($note{$_}, 0.3) } ('C4', 'E4', 'G4')
      # map { sine_gen($note{$_}, 0.3) } ('C4', 'E4')
    # ),
    # 0.1, 0.1, 0.1
  # );
my $chord =
  envelope_gen(
    combine_gen(
      map { sine_gen($note{$_}, 0.3) } ('C4', 'E4', 'G4')
      # map { beep_gen($note{$_}, 0.5, 0.3) } ('C4', 'E4', 'G4')
    ),
    0.001, 1, 1,
  );
# play($chord);
# play($chord);

# my $c = beep_gen($note{'C4'}, 1, 0.3);
# my $e = beep_gen($note{'E4'}, 1, 0.3);
# my $g = beep_gen($note{'G4'}, 1, 0.3);
# my $c = note_gen('C4');
# my $e = note_gen('E4');
# my $g = note_gen('G4');
# my @notes = ($c, $e, $g);
my @notes = map { note_gen($_) } ('C5', 'E5', 'G5');
my @notes_long = map { note_gen($_, 0.01, 1, 0.3) } ('C4', 'E4', 'G4');

# play(
  # combine_gen(
    # sequence_gen( @notes ),
    # combine_gen( @notes_long )
  # )
# );

play(
  combine_gen(
    sequence_gen(
      (map { note_gen($_) } ('C5', 'E5', 'G5')),
      rest_gen(0.3)
    ),
    combine_gen(
      map { note_gen($_, 0.01, 1, 0.3) } ('C4', 'E4', 'G4')
    ),
    note_gen('C2', 2, 0, 2),
    # sequence_gen( map { note_gen($_) } ('C2') ),
  )
);

# my $c = beep_gen($note{'C4'}, 1, 0.3);
# my $e = beep_gen($note{'E4'}, 1, 0.3);
# my $g = beep_gen($note{'G4'}, 1, 0.3);
# my $seq = sequence_gen($c, $e, $g);
# play($seq);
# play($seq);

# we can re-use $c, $e, and $g
# my $chord = combine_gen($c, $e, $g);
# play($chord);
# play($chord);