classdef PM_Figures_BarGraph
    %PM_FIGURES_BARGRAPH to make bar graph with simple input data;
    %PMNEXTCURE_CT26_FIGURES_BARGRAPH Old name

    
    properties (Access = private)
        Axes
        Data
        Titles
        XLabel
        YLabel
        PanelTitle
        MyBar


    end

    properties (Access = private)


        StatisticsTest = 'ttest'

        
        Symbol

        
        PValueText

        BarFill
        BarStroke

        Stairs


    end



    methods % initialize:

             function obj = PM_Figures_BarGraph(varargin)
            %PMNEXTCURE_CT26_FIGURES_BARGRAPH Construct an instance of this class
            %   Takes 4 arguments:
            % 1:
            % 2:
            % 3:
            % 4:
            switch length(varargin)

                case 3

                    error('Use 6 arguments')
                    obj.Axes =      varargin{1};
                    obj.Data =      varargin{2};
                    
                    obj.Titles =    'CT26';
                   
                    obj.YLabel =    'Vascular density (Mean)';


                case 4
                    obj.Axes =          varargin{1};
                    obj.Data =          varargin{2};
                    obj.Titles =        varargin{3};
                    obj.YLabel =        varargin{4};

                case 5
                    obj.Axes =          varargin{1};
                    obj.Data =          varargin{2};
                    obj.Titles =        varargin{3};
                    obj.YLabel =        varargin{4};
                    obj.PanelTitle =    varargin{5};

                otherwise
                    error('Wrong input.')



            end

                obj.Symbol.Size =           25;
                obj.Symbol.Show =           true;
                
                obj.PValueText.Show =       true;
                obj.PValueText.Height =     0.95;
                obj.PValueText.Center =     0.5;
                
                obj.BarFill =               'none';
                
                obj.BarStroke=              'red';
                
                obj.Stairs =                false;
                
                obj.XLabel =                'x';
           
             end

             function obj = set.Axes(obj, Value)
                 assert(isa(Value,'matlab.graphics.axis.Axes'), 'Wrong input.')
                 obj.Axes = Value;
             end

              function obj = set.Data(obj, Value)
                 assert(iscell(Value), 'Wrong input.')
                 cellfun(@(x)assert( isvector(x) && isnumeric(x), 'Wrong input.'), Value)
                 obj.Data = Value;

              end

               function obj = set.Titles(obj, Value)
                 assert(isempty(Value) || iscellstr(Value), 'Wrong input.')
                 obj.Titles = Value;

               end

                function obj = set.YLabel(obj, Value)
                 assert(ischar(Value), 'Wrong input.')
                 obj.YLabel = Value;

             end



    end
    
    methods
   
        
        function obj = makePanel(obj)
            %makePanel makes bar-graph with error bars and p-value;
           
            hold on
            obj =           obj.makeBars;
            
            hold on
            obj =           obj.makeSymbols;
            obj =           obj.makeErrorBars;
            obj =           obj.makePValue;

        end

        function obj = addPValueSymbols(obj, Symbols)

            for index = 1 : length(obj.Data) - 1
               MyText =           text(obj.PValueText.Center + index - 0.5,     obj.Axes.YLim(2) * obj.PValueText.Height , sprintf('%s', Symbols{index}));
            end


        end

        function myBar = getBar(obj)
            myBar = obj.MyBar;

        end

   
    end

    methods % SETTERS


        function obj = setSymbolSize(obj, Value)
                obj.Symbol.Size = Value;
        end

         function obj = setShowSymbols(obj, Value)
                obj.Symbol.Show = Value;
        end


         function obj = setBarFill(obj, Value)
                obj.BarFill = Value;
         end

        function obj = setBarStroke(obj, Value)
                obj.BarStroke = Value;
         end
        
         function obj = setShowAsStairs(obj, Value)
             obj.Stairs  = Value;
         end
        
         function obj = setXLabel(obj, Value)

             obj.XLabel = Value;

         end

        function obj = setShowPValueText(obj, Value)
                obj.PValueText.Show = Value;
        end

        function obj = setPValueTextHeight(obj, Value)
                obj.PValueText.Height = Value;
        end

        function obj = setPValueTextCenter(obj, Value)
                obj.PValueText.Center = Value;
        end
        



    end

    methods (Access = private) % GETTERS


        function Means = getMeans(obj)
              Means =                 cellfun(@(x) nanmean(x), obj.Data);
        end

        function obj = makeBars(obj)

            try
                MyTitles =              categorical(obj.Titles);
               MyTitles =               reordercats(MyTitles,obj.Titles);
            catch

            end

                MyMeans =               obj.getMeans;


                if   obj.Stairs 

                    obj.MyBar =                 stairs( obj.Axes, MyTitles(:), MyMeans(:));      
                    obj.MyBar.Color =               obj.BarStroke ;
                    
                else
                    
                    obj.MyBar =                     bar( obj.Axes, MyTitles(:), MyMeans(:));        
                    obj.MyBar.FaceColor =          obj.BarFill ;
                    obj.MyBar.EdgeColor =          obj.BarStroke ;

                end

                
                  
                    obj.MyBar.LineWidth =       2;

                MyFigure =                  obj.Axes.Parent;
                MyFigure.CurrentAxes =      obj.Axes;
                ylabel(obj.YLabel)
                xlabel( obj.XLabel)
                title(obj.PanelTitle)
                
        end

        function obj = makeSymbols(obj)

            if ~obj.Symbol.Show
                return
            end

               MyFigure = obj.Axes.Parent;
               MyFigure.CurrentAxes = obj.Axes;

               hold on
             
                for index = 1 : length(obj.Data)
                    MyScatter{index} = scatter(index, obj.Data{index}, obj.Symbol.Size, "black");

                end

        end


        function obj = makeErrorBars(obj)

               StandarErrors =                  cellfun(@(x) std(x) / sqrt(length(x)), obj.Data);

               MyFigure =                       obj.Axes.Parent;
               MyFigure.CurrentAxes =           obj.Axes;

               hold on
                
                er = errorbar(...
                                1 : length(obj.Data),  ...
                                obj.getMeans, ...
                                StandarErrors, ...
                                StandarErrors...
                );    
                
                er.Color =              [0 0 0];                            
                er.LineStyle =          'none';  
                


        end

        function obj = makePValue(obj)


            if ~obj.PValueText.Show
               
                return

            end
                for index = 1 : length(obj.Data) - 1

                    switch obj.StatisticsTest


                        case 'ttest'
                             [a, pValue] =            ttest2(obj.Data{index}, obj.Data{index + 1} );

                        otherwise
                            error('Wrong input.')

                    end
                       
                

                        
                        MyText =            text(obj.PValueText.Center + index - 0.5,     obj.Axes.YLim(2) * obj.PValueText.Height , sprintf('P = %6.5f', pValue));


                           
        

                end
               

        end



    end


end

