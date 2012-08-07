package main;
use strict;
use warnings;
use FindBin qw($Bin);
use Test::More;
use File::Spec;
use Games::TMX::Parser;
use Data::Dumper;

my $parser = Games::TMX::Parser->new(
    map_dir  => File::Spec->catfile($Bin, '..', 'eg'),
    map_file => 'tower_defense.tmx',
);

my $map = $parser->map;

is scalar(keys %{$map->layers}), 3, 'layer count';

my $waypoints_layer = $map->get_layer('waypoints');

my @spawn_cells = $waypoints_layer->find_cells_with_property('spawn_point');
my @leave_cells = $waypoints_layer->find_cells_with_property('leave_point');

is scalar(@spawn_cells), 1, 'one spawn cell';
is scalar(@leave_cells), 1, 'one leave cell';

is $map->tile_height, 25, 'tile_height correct';
is $map->tile_width, 25, 'tile_width correct';

diag "object group";
my $obj_group_rooms = $map->get_objectgroup('rooms');
isa_ok $obj_group_rooms, 'Games::TMX::Parser::ObjectGroup', 'rooms objectgroup exists';
is scalar(@{ $obj_group_rooms->list_object_names}), 5, 'all four  object types';

diag "rectangular object";
{
    my $obj_name = 'room1';
    my @pos = (2,2);
    my @obj = $obj_group_rooms->get_objects_by_name($obj_name);
    is scalar(@obj), 1, "1 object called $obj_name";
    isa_ok ref($obj[0]), 'Games::TMX::Parser::Object::Rectangle', "$obj_name is a rectangle object";
    is scalar(@{$obj[0]->positions_yx}), 9, "$obj_name is 9 square wide";
    is scalar(@{$obj_group_rooms->objects_for_position_yx(@pos)}), 1, "There is one object at [@pos]";
    is $obj_group_rooms->objects_for_position_yx( @pos )->[0]->name, 'room1', "The object at [@pos] is room1";
    diag $obj[0]->dump_object;
}

diag "tile object";
{
    my $obj_name = 'objecttile1';
    my @obj = $obj_group_rooms->get_objects_by_name($obj_name);
    is scalar(@obj), 1, "1 object called $obj_name";
    isa_ok ref($obj[0]), 'Games::TMX::Parser::Object::Tile', "$obj_name is a tile object";
    is scalar(@{$obj[0]->positions_yx}), 1, "$obj_name is 1 square wide";
    is_deeply $obj[0]->positions_yx, [[5,2]], "$obj_name is at [5,2]";
    diag $obj[0]->dump_object;
}

diag "polyline object";
{
    my $obj_name = 'polyline1';
    my @obj = $obj_group_rooms->get_objects_by_name($obj_name);
    is scalar(@obj), 1, "1 object called $obj_name";
    isa_ok ref($obj[0]), 'Games::TMX::Parser::Object::Polyline', "$obj_name is a Polyline object";
    is scalar(@{$obj[0]->positions_yx}), 16, "$obj_name is 16 squares long";
    diag $obj[0]->dump_object;
    # warn Dumper $obj[0]->positions_yx;
    # is scalar(@{$obj_group_rooms->objects_for_position_yx(@pos)}), 1, "There is one object at [@pos]";
    # is $obj_group_rooms->objects_for_position_yx( @pos )->[0]->name, 'room1', "The object at [@pos] is room1";
}

diag "polygon object";
{
    my $obj_name = 'polygon1';
    my @obj = $obj_group_rooms->get_objects_by_name($obj_name);
    is scalar(@obj), 1, "1 object called $obj_name";
    isa_ok ref($obj[0]), 'Games::TMX::Parser::Object::Polygon', "$obj_name is a Polygon object";

    diag $obj[0]->dump_object;
    # is scalar(@{$obj[0]->positions_yx}), 16, "$obj_name is 16 squares long";
    # warn Dumper $obj[0]->positions_yx;
    # is scalar(@{$obj_group_rooms->objects_for_position_yx(@pos)}), 1, "There is one object at [@pos]";
    # is $obj_group_rooms->objects_for_position_yx( @pos )->[0]->name, 'room1', "The object at [@pos] is room1";
}


done_testing;
